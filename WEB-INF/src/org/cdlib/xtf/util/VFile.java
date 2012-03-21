package org.cdlib.xtf.util;

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
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.RandomAccessFile;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.net.URI;
import java.util.HashMap;

import sun.reflect.generics.reflectiveObjects.NotImplementedException;

public abstract class VFile implements Comparable<VFile>
{
  ////////////////////////////////////////////////////////////////////////
  // Constructors
  ////////////////////////////////////////////////////////////////////////
  
  public interface Factory {
    String getFactoryName();
    boolean isAbsoluteMatch(String path);
    VFile create(String parentPath, String childPath);
  }
  
  private static HashMap<Class, Factory> factories = new HashMap<Class, Factory>();
  
  public static void addFactory(Factory factory) {
    factories.put(factory.getClass(), factory); // put before all other factories
  }
  
  public static void removeFactory(Factory factory) {
    factories.remove(factory.getClass());
  }
  
  protected VFile() { } // clients should only create using factory
  
  public static boolean isAbsolute(String path) {
    if (path == null || path.length() == 0)
      return false;
    VNativeFile.register(); // ensure at least one factory
    for (Factory factory : factories.values()) {
      if (factory.isAbsoluteMatch(path))
        return true;
    }
    return false;
  }
  
  public static VFile create(String pathname) { 
    return create(pathname, null); 
  }
  
  public static VFile createIfPossible(String pathname) { 
    return createIfPossible(pathname, null); 
  }
  
  public static VFile createIfPossible(String parentPath, String childPath)
  {
    // If the child path has a protocol, we can't possibly combine it.
    if (childPath != null && childPath.matches("^\\w\\w+:.*$"))
      return createIfPossible(childPath);
    
    // If the child path is itself absolute, just return it.
    if (isAbsolute(childPath))
      return VFile.createIfPossible(childPath);

    VFile retFile = null;
    Factory retFactory = null;
    
    VNativeFile.register(); // ensure at least one factory
    for (Factory factory : factories.values()) 
    {
      VFile f = factory.create(parentPath, childPath);
      if (f != null) {
        if (retFile != null) {
          throw new RuntimeException(
              String.format("Error: two factories '%s' and '%s' want to create VFile for path '%s'",
                  retFactory.getFactoryName(), factory.getFactoryName(), parentPath));
        }
        retFile = f;
        retFactory = factory;
      }
    }
    return retFile;
  }
  
  public static VFile create(String parentPath, String childPath)
  {
    VFile retFile = createIfPossible(parentPath, childPath);
    if (retFile == null) {
      throw new RuntimeException(
          String.format("Error: no factory wants to create VFile for path '%s'", parentPath));
    }
    return retFile;
  }
  
  public static VFile create(VFile parent, String childPath)
  {
    return parent.resolve(childPath);
  }
  
  ////////////////////////////////////////////////////////////////////////
  // Mandatory overrides (not present in java.io.File)
  ////////////////////////////////////////////////////////////////////////
  
  public abstract VFile resolve(String childPath);
  public abstract InputStream openInputStream() throws IOException;   
  public abstract OutputStream openOutputStream(boolean append) throws IOException;
  public abstract RandomAccessFile openRandomAccessFile(String mode) throws IOException;
  public abstract String getName();
  public abstract VFile getParentFile();
  public abstract boolean isAbsolute();
  public abstract String getPath();
  public abstract VFile getAbsoluteFile();
  public abstract VFile getCanonicalFile() throws IOException;
  public abstract URI toURI();
  public abstract boolean canRead();
  public abstract boolean exists();
  public abstract boolean isDirectory();
  public abstract boolean isFile();
  public abstract long lastModified();
  public abstract long length();
  public abstract boolean delete();
  public abstract VFile[] listFiles();
  public abstract boolean mkdir();
  public abstract boolean mkdirs();
  public abstract boolean renameTo(VFile dest);


  ////////////////////////////////////////////////////////////////////////
  // Optional overrides (not present in java.io.File)
  ////////////////////////////////////////////////////////////////////////
  
  /** Only works for native files. */
  public java.io.File getNativeFile() { throw new NotImplementedException(); }

  ////////////////////////////////////////////////////////////////////////
  // Extra methods not present in java.io.File
  ////////////////////////////////////////////////////////////////////////
  
  public final OutputStream openOutputStream() 
    throws IOException
  {
    return openOutputStream(false);
  }
  
  public final Reader openReader() 
    throws IOException 
  {
    try {
      return new InputStreamReader(openInputStream(), "UTF-8");
    } catch (UnsupportedEncodingException e) {
      throw new RuntimeException(e);
    }
  }

  public final BufferedReader openBufferedReader() 
    throws IOException 
  {
    return new BufferedReader(openReader());
  }

  public final Writer openWriter() 
    throws IOException 
  {
    return openWriter(false);
  }

  public final BufferedWriter openBufferedWriter() 
    throws IOException 
  {
    return new BufferedWriter(openWriter());
  }

  public final Writer openWriter(boolean append) 
    throws IOException 
  {
    return new OutputStreamWriter(openOutputStream(append), "UTF-8");
  }
  
  public static VFile createTempFile(String prefix, String suffix) 
    throws IOException
  {
    return VFile.create(File.createTempFile(prefix, suffix).toString());
  }
  
  public static VFile createTempFile(String prefix, String suffix, VFile directory) 
    throws IOException
  {
    return VFile.create(File.createTempFile(prefix, suffix, directory.getNativeFile()).toString());
  }

  public final String getParent() {
    return getParentFile().getPath();
  }

  public final String getAbsolutePath() {
    return getAbsoluteFile().getPath();
  }

  public final String getCanonicalPath() throws IOException {
    return getCanonicalFile().getPath();
  }

  public final String[] list() {
    VFile[] files = listFiles();
    String[] ret = new String[files.length];
    for (int i=0; i<files.length; i++)
      ret[i] = files[i].getName();
    return ret;
  }

  public final int compareTo(VFile pathname) {
    return getPath().compareTo(pathname.getPath());
  }

  public final boolean equals(Object obj) {
    return obj instanceof VFile && ((VFile)obj).getPath().equals(getPath());
  }

  public final int hashCode() {
    return getPath().hashCode();
  }

  public final String toString() {
    return getPath();
  }

}
