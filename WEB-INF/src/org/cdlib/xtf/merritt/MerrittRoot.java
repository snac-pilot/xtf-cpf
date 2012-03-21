package org.cdlib.xtf.merritt;

/**
 * Copyright (c) 2011, Regents of the University of California
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of the University of California nor the names of its
 *   contributors may be used to endorse or promote products derived from this
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.lang.ref.WeakReference;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cdlib.xtf.textIndexer.HTMLToString;
import org.cdlib.xtf.util.EasyNode;
import org.cdlib.xtf.util.Trace;
import org.cdlib.xtf.util.VFile;

/**
 * Represents the top-level directory of a Merritt collection. Essentially just tracks
 * the identifiers in the repo and allows traversing them.
 */
public class MerrittRoot extends VAbstractDir
{
  // Class static variables
  private static VFile xtfHomeDir;
  private static long collectionInfoTime = 0;
  private static HashMap<String, CollectionInfo> collections = new HashMap<String, CollectionInfo>();
  private static HashMap<String, WeakReference<MerrittRoot>> openCollections = new HashMap<String, WeakReference<MerrittRoot>>();

  // Class static methods
  
  // Update collection info from the 'conf/merritt.conf' file.
  private static synchronized void updateCollections()
  {
    // Check at most once a second.
    long lastCheck = collectionInfoTime;
    collectionInfoTime = System.currentTimeMillis();
    if (collectionInfoTime - lastCheck < 1000)
      return;
    
    VFile confFile = xtfHomeDir.resolve("conf/merritt.conf");
    if (!confFile.canRead())
      throw new RuntimeException(String.format("Error opening merritt config file '%s'", confFile.toString()));
    
    // Cache prior results if possible
    if (confFile.lastModified() < lastCheck)
      return;
    
    // Clear out and re-read.
    collections.clear();
    for (EasyNode node : EasyNode.readXMLFile(xtfHomeDir.resolve("conf/merritt.conf")).descendants())
    {
      if ("".equals(node.name()) || "merritt-config".equals(node.name()))
        continue;
      assert "collection".equals(node.name());
      collections.put(node.attrValue("name"), new CollectionInfo(
          node.attrValue("name"),
          node.attrValue("server"),
          node.attrValue("collection"),
          node.attrValue("group"),
          node.attrValue("username"),
          node.attrValue("password")));
    }
    
    if (collections.isEmpty())
      throw new RuntimeException(String.format("Error: no collections defined in '%s'", confFile.toString()));
  }
  
  private static synchronized CollectionInfo findCollection(String collectionName)
  {
    updateCollections();
    return collections.get(collectionName);
  }
  
  // Make sure all Merritt URLs go through us.
  public static void register(VFile _xtfHomeDir)
  {
    xtfHomeDir = _xtfHomeDir;
    
    VFile.addFactory(new VFile.Factory() 
    {
      public String getFactoryName() { return "Merritt factory"; }
      private final Pattern matchPat = Pattern.compile("^merritt://([^/]+)(/(.*))?$");
      public boolean isAbsoluteMatch(String path) {
        return matchPat.matcher(path).matches();
      }
      public VFile create(String parentPath, String childPath) 
      {
        // We only handle things with the "merritt:" prefix
        Matcher m = matchPat.matcher(parentPath);
        if (!m.matches()) {
          assert !parentPath.startsWith("merritt://");
          return null;
        }
        
        // Get the repo name.
        String collName = m.group(1);
        
        // If not already open, open it.
        WeakReference<MerrittRoot> ref = openCollections.get(collName);
        MerrittRoot root = ref != null ? ref.get() : null;
        if (root == null)
          root = open(collName);
        
        // Stick on the child path.
        VFile sub = root.resolve(m.group(3));
        return sub.resolve(childPath);
      }
    });
  }
  
  private static MerrittRoot open(String collName)
  {
    CollectionInfo coll = findCollection(collName);
    MerrittRoot root = new MerrittRoot(coll);
    openCollections.put(collName, new WeakReference<MerrittRoot>(root));
    return root;
  }
  
  // Instance variables
  private HashMap<String, ObjDir> idEntries = new HashMap<String, ObjDir>();
  CollectionInfo collection;
  private boolean contentsListed = false;
  private URI repoURI;
  
  /** Should only create through the static open() method above */
  protected MerrittRoot(CollectionInfo coll)
  {
    super(null, String.format("merritt://%s", coll.name));
    try {
      this.collection = coll;
      repoURI = new URI("http://" + collection.server);
    } catch (URISyntaxException e) {
      throw new RuntimeException(e);
    }
  }
  
  public void update(boolean clean) 
    throws IOException
  {
    try 
    {
      URL nextPageLink = repoURI.resolve(new URI("/object/recent.atom?collection=" + 
          URLEncoder.encode(collection.id, "UTF-8"))).toURL();
      while (nextPageLink != null)
      {
        InputStream inStream = collection.urlOpener.openInputStream(nextPageLink);

        // Parse the feed (it should be XML)
        Reader reader = new BufferedReader(new InputStreamReader(inStream, "UTF-8"));
        EasyNode feedData = EasyNode.readXMLFile(reader, nextPageLink.toString());
        
        if (!"feed".equals(feedData.child(0).name()))
            throw new RuntimeException("Merritt did not return a <feed>");
        
        // And traverse it.
        nextPageLink = null;
        for (EasyNode child : feedData.child(0)) 
        {
          // Record link to the next page in the feed if present
          if ("link".equals(child.name()) && 
              "application/atom+xml".equals(child.attrValue("type")) &&
              "next".equals(child.attrValue("rel")))
          {
            String tmp = child.attrValue("href");
            nextPageLink = repoURI.resolve(tmp).toURL();
          }
          
          // Grab entries and parse them out
          else if ("entry".equals(child.name()))
            parseEntry(child);
          
          // Testing only - stop after first item on page
          //if ("entry".equals(child.name())) break;
        }
        
        // Testing only - stop after first page
        //nextPageLink = null;
        
        reader.close();
      }
    } catch (URISyntaxException e) {
      throw new RuntimeException(e);
    }
  }
  
  public VFile resolve(String childPath)
  {
    if (childPath == null || childPath.length() == 0)
      return this;
    
    // Get the identifier and path
    final Pattern pat = Pattern.compile("^id=([^/]+)/?(.*$)");
    Matcher m = pat.matcher(childPath);
    if (!m.matches())
      throw new RuntimeException("Error parsing merritt id path from '" + childPath + "'");
    
    // Locate the correct child
    String id = m.group(1);
    id = id.replaceAll("%2F", "/");
    ObjDir child = idEntries.get(id);
    if (child == null)
      child = addSuddenChild(id);
    
    // Strip off the child's part of the path.
    if (!childPath.startsWith(child.getName()))
      throw new RuntimeException("Error stripping child name from path");
    childPath = childPath.substring(child.getName().length());
    if (childPath.startsWith("/"))
      childPath = childPath.substring(1);
    
    // And delegate the rest of the work to it.
    return child.resolve(childPath);
  }

  /** Process one entry of the Atom feed */
  private void parseEntry(EasyNode entryNode) 
  {
    // We're going to use this pattern to parse URLs
    Pattern pat = Pattern.compile(".*file=producer([^&;]+).*");
    // Grab the id and all the parts
    String id = null;
    long modTime = 0;
    int nFilesFound = 0;
    for (EasyNode child : entryNode)
    {
      // Extract the identifier
      if ("id".equals(child.name())) {
        id = child.toString();
        if (id.indexOf("ark:") > 0)
          id = id.substring(id.indexOf("ark:"));
        Trace.info("Found id=" + id);
      }
      
      // Extract the update time
      else if ("updated".equals(child.name()))
      {
        String timeStr = child.toString();
        DateFormat fmt = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
        try {
          Date modDate = fmt.parse(timeStr);
          modTime = modDate.getTime();
        } catch (ParseException e) {
          Trace.warning("Unable to parse feed time '%s'", timeStr);
          continue;
        }
      }
      
      // Extract file parts
      else if ("link".equals(child.name()) && "http://purl.org/dc/terms/hasPart".equals(child.attrValue("rel")))
      {
        try {
          // Extract the path from the href
          String href = child.attrValue("href");
          Matcher m = pat.matcher(href);
          if (!m.matches())
            continue;
          String path = URLDecoder.decode(m.group(1), "UTF-8");
          if (path.startsWith("/"))
            path = path.substring(1);
          
          assert id != null;
          assert modTime != 0;
          addPath(path, id, modTime, href);
          ++nFilesFound;
        } catch (UnsupportedEncodingException e) {
          throw new RuntimeException(e);
        }
        
      }
    }
    if (nFilesFound == 0)
      Trace.warning("Warning: Could not find files in Atom entry for id '%s'", id); 
  }

  /**
   * If a URL was specified for scanning child files, do it once.
   * @return 
   */
  private ObjDir addSuddenChild(String id) 
  {
    if (contentsListed)
      throw new RuntimeException("Error: id '" + id + "' not in Merritt repo -- how did you get this id?");
    
    try 
    {
      // Create a new node for the child
      ObjDir child = new ObjDir(this, "id=" + id.replaceAll("/", "%2F"));
      
      // Figure out a URL to get a list of its files.
      // FIXME: Kludged to add 'group' parameter, since server can't seem to use 'collection' here
      URI listingURI = repoURI.resolve(
          new URI(String.format("/version?group=%s&object=%s&version=0",
                                collection.group, URLEncoder.encode(id, "UTF-8"))));
      
      // Grab the data and parse it (convert to well-formed XHTML first)
      InputStream inStream = collection.urlOpener.openInputStream(listingURI.toURL());
      String htmlXMLStr = HTMLToString.convert(inStream);
      inStream.close();
      EasyNode xmlData = EasyNode.readXMLFile(new StringReader(htmlXMLStr), listingURI.toString());
      
      // And traverse it.
      LinkedList<EasyNode> nodesToScan = new LinkedList<EasyNode>();
      nodesToScan.add(xmlData);
      
      Pattern linkPat = Pattern.compile(".*file=producer/([^&;]+).*");
      
      while (!nodesToScan.isEmpty()) 
      {
        EasyNode node = nodesToScan.removeFirst();
        
        // Look for file links.
        if ("a".equals(node.name())) {
          String href = node.attrValue("href");
          Matcher m = linkPat.matcher(URLDecoder.decode(href, "UTF-8"));
          if (m.matches()) {
            String path = m.group(1);
            // FIXME: Kludge until we figure out how to get most recent version
            href = href.replaceAll("version=0", "version=1");
            try {
              idEntries.put(id, child);
              addPath(path, id, System.currentTimeMillis(), repoURI.resolve(href).toString());
            }
            finally {
              idEntries.remove(id);
            }
          }
        }
        
        // Scan all sub-nodes
        for (EasyNode sub : node)
          nodesToScan.add(sub);
      }
      
      // All done.
      idEntries.put(id, child);
      return child;
    } catch (MalformedURLException e) {
      throw new RuntimeException(e);
    } catch (UnsupportedEncodingException e) {
      throw new RuntimeException(e);
    } catch (IOException e) {
      throw new RuntimeException(e);
    } catch (URISyntaxException e) {
      throw new RuntimeException(e);
    }
  }

  private void addPath(String path, String id, long modTime, String href) 
  {
    // Get the components of the path
    String[] parts = path.split("/");
    
    // Make a container directory to hold the contents if we haven't already
    ObjDir addTo = idEntries.get(id);
    if (addTo == null) {
      addTo = new ObjDir(this, "id=" + id.replaceAll("/", "%2F"));
      idEntries.put(id, addTo);
    }
    
    // Add directories along the way
    for (int i=0; i<parts.length-1; i++) 
    {
      String name = parts[i];
      ObjDir sub = (ObjDir) addTo.getChild(name);
      if (sub == null) {
        sub = new ObjDir(addTo, name);
        addTo.addChild(sub);
      }
      addTo = sub;
    }
    
    // Add the file at the end.
    try {
      URI fileURI = repoURI.resolve(new URI(href));
      // FIXME: Kludge to add group to URLs, not sure why we need to but they say they'll fix it.
      if (!fileURI.toString().contains("group="))
        fileURI = new URI(fileURI.toString() + "&group=" + collection.group);
      ObjFile file = new ObjFile(addTo, parts[parts.length-1], modTime, collection.urlOpener, fileURI);
      addTo.addChild(file);
    } catch (URISyntaxException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public VFile[] listFiles() 
  {
    // We only need to crawl the inventory service if listing files.
    if (!contentsListed) {
      try {
        update(true); // we don't support incremental yet
      }
      catch (IOException e) { 
        throw new RuntimeException(e); 
      }
    }
    
    ArrayList<String> ids = new ArrayList<String>(idEntries.keySet());
    Collections.sort(ids);
    VFile[] out = new VFile[ids.size()];
    for (int i=0; i<ids.size(); i++)
      out[i] = idEntries.get(ids.get(i));
    return out;
  }
  
  /** All the information about repos we have open. */
  private static class CollectionInfo
  {
    String name;
    String server;
    String id;
    String group;
    URLOpener urlOpener;
    
    CollectionInfo(String name, String server, String id, String group, String username, String password) {
      this.name = name;
      this.server = server;
      this.id = id;
      this.group = group;
      this.urlOpener = new URLOpener(username, password);
    }
  }
  
}
