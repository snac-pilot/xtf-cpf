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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.URI;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.cdlib.xtf.util.VFile;

public class ObjFile extends VAbstractFile
{
  private URLOpener opener;
  private URI uri;
  private long modTime;
  private WeakReference<byte[]> dataRef;

  public ObjFile(VFile parent, String name, long modTime, URLOpener opener, URI fileURI) {
    super(parent, name);
    this.opener = opener;
    this.modTime = modTime;
    this.uri = fileURI;
  }
  
  private byte[] fetch() throws IOException
  {
    // If already fetched but not yet garbage collected, we can re-use the data.
    byte[] data = dataRef != null ? dataRef.get() : null;
    if (data != null)
      return data;
    
    // Read all the bytes and store them.
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    InputStream in = opener.openInputStream(uri.toURL());
    byte[] buf = new byte[16384];
    while (true)
    {
      int n = in.read(buf);
      if (n < 0)
        break;
      out.write(buf, 0, n);
    }
    
    // Gather up the result.
    data = out.toByteArray();
    dataRef = new WeakReference<byte[]>(data);
    return data;
  }

  @Override
  public InputStream openInputStream() throws IOException
  {
    return new ByteArrayInputStream(fetch());
  }

  @Override
  public boolean isDirectory() {
    return false;
  }
  
  @Override
  public boolean isFile() {
    return true;
  }
  
  @Override
  public long lastModified() {
    return modTime;
  }
  
  @Override
  public long length() 
  {
    try {
      return fetch().length;
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
  
  @Override
  public VFile resolve(String childPath) {
    assert(childPath == null || childPath.length() == 0);
    return this;
  }
}
