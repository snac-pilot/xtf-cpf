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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.net.URI;
import java.util.regex.Pattern;

public class VNativeFile extends VFile
{
  private File wrapped;
  
  private static boolean registered = false;
  
  // Pick up local filesystem paths with this class.
  public static void register()
  {
    if (registered)
      return;
    
    VFile.addFactory(new VFile.Factory() 
    {
      public String getFactoryName() { return "VNativeFile factory"; }
      private final Pattern matchPat = Pattern.compile("(/.*)|(file:/.*)|(\\w:.*)");
      public boolean isAbsoluteMatch(String path) {
        return matchPat.matcher(path).matches();
      }
      public VFile create(String parentPath, String childPath) 
      {
        // Ensure that either there's no protocol prefix, or it's "file:/"
        if (parentPath.startsWith("/") ||
            parentPath.startsWith("file:/") ||
            !parentPath.matches("^\\w\\w+:.*$")) // to allow for "C:\dir\file" but not "http://dir/file"
        {
          if (parentPath.startsWith("file:/"))
            parentPath = parentPath.substring("file:/".length());
          File toWrap = new File(parentPath);
          if (childPath != null)
            toWrap = new File(toWrap, childPath);
          return new VNativeFile(toWrap);
        }
        else
          return null;
      }
    });
    
    registered = true;
  }
  
  ////////////////////////////////////////////////////////////////////////
  // Constructors
  ////////////////////////////////////////////////////////////////////////
  
  /** VNativeFile should only be constructed by calling VFile.create(...) */
  protected VNativeFile(File toWrap) { 
    wrapped = toWrap;
  }
  
  ////////////////////////////////////////////////////////////////////////
  // Mandatory overrides
  ////////////////////////////////////////////////////////////////////////
  
  @Override
  public InputStream openInputStream() 
    throws IOException 
  {
    return new FileInputStream(wrapped);
  }
  
  @Override
  public OutputStream openOutputStream(boolean append) 
    throws IOException 
  {
    return new FileOutputStream(wrapped, append);
  }
  
  @Override
  public RandomAccessFile openRandomAccessFile(String mode) 
    throws IOException
  {
    return new RandomAccessFile(wrapped, mode);
  }
  
  @Override
  public VFile resolve(String childPath)
  {
    return new VNativeFile(new File(wrapped, childPath));
  }

  /** Only use this in extreme need */
  @Override
  public File getNativeFile() {
    return wrapped;
  }

  ////////////////////////////////////////////////////////////////////////
  // Wrapped methods
  ////////////////////////////////////////////////////////////////////////
  
  @Override
  public String getName() {
    return wrapped.getName();
  }

  @Override
  public VNativeFile getParentFile() {
    File wParent = wrapped.getParentFile();
    return wParent == null ? null : new VNativeFile(wParent);
  }

  @Override
  public String getPath() {
    return wrapped.getPath();
  }

  @Override
  public boolean isAbsolute() {
    return wrapped.isAbsolute();
  }

  @Override
  public VNativeFile getAbsoluteFile() {
    File target = wrapped.getAbsoluteFile();
    return (target == wrapped) ? this : new VNativeFile(target);
  }

  @Override
  public VNativeFile getCanonicalFile() throws IOException {
    File target = wrapped.getCanonicalFile();
    return (target == wrapped) ? this : new VNativeFile(target);
  }

  @Override
  public URI toURI() {
    return wrapped.toURI();
  }

  @Override
  public boolean canRead() {
    return wrapped.canRead();
  }

  @Override
  public boolean exists() {
    return wrapped.exists();
  }

  @Override
  public boolean isDirectory() {
    return wrapped.isDirectory();
  }

  @Override
  public boolean isFile() {
    return wrapped.isFile();
  }

  @Override
  public long lastModified() {
    return wrapped.lastModified();
  }

  @Override
  public long length() {
    return wrapped.length();
  }

  @Override
  public boolean delete() {
    return wrapped.delete();
  }

  @Override
  public VNativeFile[] listFiles() {
    File[] files = wrapped.listFiles();
    if (files == null)
      return null;
    VNativeFile[] ret = new VNativeFile[files.length];
    for (int i=0; i<files.length; i++)
      ret[i] = new VNativeFile(files[i]);
    return ret;
  }

  @Override
  public boolean mkdir() {
    return wrapped.mkdir();
  }

  @Override
  public boolean mkdirs() {
    return wrapped.mkdirs();
  }

  @Override
  public boolean renameTo(VFile dest) {
    return wrapped.renameTo(dest.getNativeFile());
  }

}
