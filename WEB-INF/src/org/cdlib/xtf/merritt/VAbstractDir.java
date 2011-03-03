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

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.net.URI;
import java.net.URISyntaxException;

import org.cdlib.xtf.util.VFile;

import sun.reflect.generics.reflectiveObjects.NotImplementedException;

public abstract class VAbstractDir extends VFile
{
  protected VFile parent;
  private String name;
  private String cachedPath;
  
  protected VAbstractDir(VFile parent, String name)
  {
    this.parent = parent;
    this.name = name;
  }
  
  /////////////////////////////////////////////////////////////////////////////
  // Methods you must override
  /////////////////////////////////////////////////////////////////////////////
  
  @Override public abstract VFile[] listFiles();
  
  /////////////////////////////////////////////////////////////////////////////
  // Optional overrides
  /////////////////////////////////////////////////////////////////////////////
  
  @Override
  public VFile getParentFile() {
    return parent;
  }

  @Override public String getName() {
    return name;
  }

  @Override
  public String getPath() {
    if (cachedPath == null) {
      String parentPath = (parent == null) ? "" : parent.getPath();
      if (parentPath.isEmpty() || parentPath.endsWith("/") || name.startsWith("/"))
        cachedPath = parentPath + name;
      else
        cachedPath = parentPath + "/" + name;
    }
    return cachedPath;
  }

  @Override
  public boolean isAbsolute() {
    return getPath().startsWith("/") || getPath().matches("^\\w\\w+://.*$");
  }

  @Override
  public VFile getAbsoluteFile() {
    return this;
  }

  @Override
  public VFile getCanonicalFile() throws IOException {
    return this;
  }

  @Override
  public URI toURI() 
  {
    try {
      String path = getPath();
      return new URI(path);
    } catch (URISyntaxException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public boolean canRead() { return true; }

  @Override
  public boolean exists() { return true; }

  @Override
  public boolean isDirectory() { return true; }

  @Override
  public boolean isFile() { return false; }

  /////////////////////////////////////////////////////////////////////////////
  // Not-implemented (though if you really want to you can)
  /////////////////////////////////////////////////////////////////////////////
  
  @Override public InputStream openInputStream() throws IOException { throw new NotImplementedException(); };
  @Override public OutputStream openOutputStream(boolean append) throws IOException { throw new NotImplementedException(); }
  @Override public RandomAccessFile openRandomAccessFile(String mode) throws IOException { throw new NotImplementedException(); }
  @Override public File getNativeFile() { throw new NotImplementedException(); }
  @Override public long lastModified() { throw new NotImplementedException(); }
  @Override public long length() { throw new NotImplementedException(); }
  @Override public boolean delete() { throw new NotImplementedException(); }
  @Override public boolean mkdir() { throw new NotImplementedException(); }
  @Override public boolean mkdirs() { throw new NotImplementedException(); }
  @Override public boolean renameTo(VFile dest) { throw new NotImplementedException(); }
}
