package org.cdlib.xtf.util;


/**
 * Copyright (c) 2004, Regents of the University of California
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
import org.cdlib.xtf.util.VFile;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.regex.Pattern;

////////////////////////////////////////////////////////////////////////////////

/** The <code>Path</code> class provides a number of utilities that makes
 *  working with file system paths easier. This class is effectively a
 *  "package" in that all its members are static, and do not rely on
 *  instance variables. <br><br>
 */
public class Path 
{
  static final Pattern winDrivePat = Pattern.compile("^[a-z]:");
  
  ////////////////////////////////////////////////////////////////////////////// 

  /** Normalize the specified file system path. <br><br>
   *
   *  This function performs a number of "cleanup" operations to create
   *  a standardized (or normalized) path. These operations include: <br><br>
   *
   *  - Stripping any leading or trailing spaces from the passed in path.
   *    <br><br>
   *
   *  - Converts DOS/Windows paths (with backslash characters) into UNIX
   *    standard format (with forward slash characters.) <br><br>
   *
   *  - Removes any double slash characters that may have been created
   *    when two partial path strings were concatenated. <br><br>
   *
   *  - Converts drive letters to uppercase (in Windows)
   *
   *  - Removes any occurrences of "./"
   *
   *  - Removes any occurrences of "xxx/../"
   *
   *  - Finally, if the resulting path is not an empty string, this function
   *    guarantees that the path ends in a slash character, in anticipation
   *    of a filename being tacked on to the end. <br><br>
   *
   *  @param  path  The path to normalize. <br><br>
   *
   *  @return
   *    A normalized version of the original path string passed.
   */
  public final static String normalizePath(String path) 
  {
    try
    {
      // Make a canonical path out of it, somehow.
      String ret; 
      if (VFile.isAbsolute(path))
        ret = VFile.create(path.trim()).getCanonicalPath();
      else {
        ret = path;
        while (ret.startsWith("./") || ret.startsWith(".\\"))
          ret = ret.substring(2);
      }
      
      // Replace windows backslashes
      ret = ret.replaceAll("\\\\", "/");
      
      // Convert Windows drive letters to upper case
      if (winDrivePat.matcher(ret).matches())
        ret = ret.substring(0, 1).toUpperCase() + ret.substring(2);
      
      // Add a trailing slash if not already present.
      if (!ret.isEmpty() && !ret.endsWith("/"))
        ret += "/";
      
      // All done.
      return ret;
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  /** Normalize a file name. <br><br>
   *
   *  This function performs a number of "cleanup" operations to create
   *  a standardized (or normalized) file name. <br><br>
   *
   *  @param  path  The file name (optionally preceeded by a path)
   *                to normalize. <br><br>
   *
   *  @return
   *    A normalized version of the original file name string passed.
   *
   *  @.notes
   *    This function does its work by calling the
   *    {@link Path#normalizePath(String) normalizePath() }
   *    function to normalize the filename and path (if any), and then
   *    simply removes the trailing slash.
   */
  public final static String normalizeFileName(String path) 
  {
    String ret = normalizePath(path);
    if (!ret.isEmpty() && ret.endsWith("/"))
      ret = ret.substring(0, ret.length() - 1);
    return ret;
  } // normalizeFileName()

  //////////////////////////////////////////////////////////////////////////////

  /** Normalize a path or file name. <br><br>
   *
   *  This function performs a number of "cleanup" operations to create
   *  a standardized (or normalized) file name. <br><br>
   *
   *  @param  pathOrFileName  The path or file name (optionally preceeded by
   *                          a path) to normalize. <br><br>
   *
   *  @return
   *    A normalized version of the original file name string passed.
   *
   *  @.notes
   *    This function does its work by calling the
   *    {@link Path#normalizePath(String) normalizePath() }
   *    function to normalize the filename and path (if any). If the original
   *    path ended with a slash, the new one will also. If not, the new one
   *    will not.
   */
  public final static String normalize(String pathOrFileName) {
    pathOrFileName = pathOrFileName.trim();
    if (pathOrFileName.endsWith("/") || pathOrFileName.endsWith("\\"))
      return normalizePath(pathOrFileName);
    else
      return normalizeFileName(pathOrFileName);
  } // public normalize()

  //////////////////////////////////////////////////////////////////////////////

  /** Create the specified file system path. <br><br>
   *
   *  This function creates the specified file system path if it does not
   *  already exist.
   *
   *  @param  path  The file system path to create. <br><br>
   *
   *  @return
   *    <code>true</code> - The file system path was successfully created. <br>
   *    <code>false</code> - An file system path was <b>not</b> created
   *                         due to errors. <br><br>
   *
   *  @.notes
   *    This method calls the function
   *    {@link Path#normalizePath(String) normalizePath()} to help ensure the
   *    successful creation of the specified path. <br><br>
   *
   *    Any directories specified in the path that do not already exist are
   *    created. Thus, this function can create paths where some or none of
   *    the parent directories exist. <br><br>
   */
  public final static boolean createPath(String path) 
  {
    boolean ret = false;

    // First normalize the path name.
    VFile thePath = VFile.create(normalizePath(path));

    // Then, if the specified path exists, return early.
    if (thePath.exists())
      return true;

    // If the path did not exist, make it now.
    ret = thePath.mkdirs();

    // Tell the caller how we did making the new path.
    return ret;
  } // public createPath()

  //////////////////////////////////////////////////////////////////////////////

  /** Remove the specified path from the file system. <br><br>
   *
   *  This function removes directories from the specified path, starting with
   *  the lowest directory and moving up until either the entire path has been
   *  removed or a non-empty directory is encountered. <br><br>
   *
   *  @param  path  The file system path to remove. <br><br>
   *
   *  @return
   *    <code>true</code> - Part or all of the specified path was removed. <br>
   *    <code>false</code> - None of the specified path could be removed
   *                         (either because none of the directories in the
   *                         path were empty, or because of other errors.)
   *                         <br><br>
   */
  public final static boolean deletePath(String path) 
  {
    VFile f = VFile.create(path);

    // Try to delete the file, then its parent directory, and so on. Eventually
    // File.delete() will return false when we get to a non-empty directory.
    //
    int nDeleted = 0;
    for (; f.delete(); f = f.getParentFile())
      nDeleted++;

    // Let the caller know whether we managed to delete anything.  
    return nDeleted > 0;
  } // public deletePath() 

  //////////////////////////////////////////////////////////////////////////////

  /**
   * Find the part of the long path that, when all symbolic links are fully
   * resolved, maps to the short path (when the short path also is fully
   * resolved.)
   */
  public final static String calcPrefix(String longPath, String shortPath)
    throws IOException 
  {
    // Find the part of the long path that, when all symlinks are fully
    // resolved, maps to the short path when it's fully resolved.
    //
    VFile normShort = VFile.create(shortPath).getCanonicalFile();
    VFile normLong = VFile.create(longPath).getCanonicalFile();

    while (normLong != null) 
    {
      if (normLong.equals(normShort))
        return normalizePath(normLong.toString());

      // Strip one directory from the end of the long path, and try again.
      normLong = normLong.getParentFile();
    } // while( true )
    
    return null;
  } // public calcPrefix() 

  /**
   * Utility function to delete a specified directory and all its files and
   * subdirectories. <br><br>
   *
   * @throws IOException if we fail to delete the entire directory and all
   *                     sub-files and subdirectories.
   */
  public static void deleteDir(VFile dir) throws IOException 
  {
    // If the specified directory exists...
    if (dir.isDirectory()) 
    {
      // Get it's contents.
      String[] children = dir.list();

      //  Delete the contents of the directory.
      for (int i = 0; i < children.length; i++) 
        deleteDir(VFile.create(dir, children[i]));
    } // if( dir.isDirectory() )

    // At this point we either have a file or an empty directory, so 
    // delete it directly.
    //
    if (dir.canRead() && !dir.delete()) {
      throw new IOException("Unable to delete '" + dir.toString() + "'");
    }
  } // deleteDir()

  /**
   * Utility function to resolve a child path against a parent path. Unlike
   * the File(File,String) constructor, this first checks if the child
   * path is absolute. If it is, the parent file is completely ignored.
   *
   * @param parentDir - Directory against which to resolve the child,
   *                     <b>if</b> the child is a relative path.
   * @param childPath - An absolute path, or else a relative path to
   *                    resolve against <code>parentFile</code>.
   * @return - The resulting fully resolved path.
   */
  public static String resolveRelOrAbs(VFile parentDir, String childPath) {
    if (parentDir == null || VFile.isAbsolute(childPath))
      return normalize(childPath);
    return normalize(resolveRelOrAbs(parentDir.toString(), childPath));
  } // resolveRelOrAbs()

  /**
   * Utility function to resolve a child path against a parent path. Unlike
   * the File(File,String) constructor, this first checks if the child
   * path is absolute. If it is, the parent file is completely ignored.
   *
   * @param parentDir - Directory against which to resolve the child,
   *                     <b>if</b> the child is a relative path.
   * @param childPath - An absolute path, or else a relative path to
   *                    resolve against <code>parentFile</code>.
   * @return - The resulting fully resolved path.
   */
  public static String resolveRelOrAbs(String parentDir, String childPath) 
  {
    childPath = normalize(childPath);
    if (parentDir == null)
      return childPath;
    parentDir = normalizePath(parentDir);

    // If the child path is absolute, just return it.
    if (VFile.isAbsolute(childPath))
      return childPath;

    // Otherwise, resolve against the parent.
    return parentDir + childPath;
  } // resolveRelOrAbs()

  /** Copies a source file to the specified destination. Creates the
   *  destination file if it doesn't exist; overwrites it otherwise.
   */
  public static void copyFile(VFile src, VFile dst)
    throws IOException 
  {
    InputStream in = src.openInputStream();
    OutputStream out = dst.openOutputStream();

    // Transfer bytes from in to out
    byte[] buf = new byte[(int)Math.min(src.length(), 1024 * 256)];
    int len;
    while ((len = in.read(buf)) > 0)
      out.write(buf, 0, len);
    in.close();
    out.close();
  } // copyFile()

  // Perform a basic regression test on the Path routines.
  public static final Tester tester = new Tester("Path") 
  {
    protected void testImpl()
      throws Exception 
    {
      String x;

      x = Path.normalizeFileName("xyz/./foo.txt/");
      assert x.equals("xyz/foo.txt");

      x = Path.normalizeFileName("./foo/bar.txt");
      assert x.equals("foo/bar.txt");

      x = Path.normalize("/usr/tmp/../foo/bar.txt");
      assert x.equals("/usr/foo/bar.txt");

      x = Path.normalize("/usr/local/tmp/../../foo/bar/");
      assert x.equals("/usr/foo/bar/");
    } // testImpl()
  };
} // class Path
