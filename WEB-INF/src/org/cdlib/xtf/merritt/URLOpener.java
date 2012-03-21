package org.cdlib.xtf.merritt;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import org.cdlib.xtf.util.Trace;

import net.sf.saxon.value.Base64BinaryValue;

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

/**
 * Utility class to wrap up credentials for opening a URL
 */
public class URLOpener
{
  private String username;
  private String password;
  
  /** Constructor with no authentication */
  public URLOpener()
  {
    this.username = null;
    this.password = null;
  }

  /** Constructor records the user name and password. */
  public URLOpener(String username, String password)
  {
    this.username = username;
    this.password = password;
  }

  /** 
   * Open the input stream for a given URL, passing the user name and password 
   * using HTTP Basic authentication.
   */
  public InputStream openInputStream(URL url) throws IOException 
  {
    URLConnection conn = url.openConnection();
    
    // Add authentication info if supplied
    if (username != null && password != null && username.length() > 0 && password.length() > 0) 
    {
      String authString = username + ":" + password;
      String auth64 = new Base64BinaryValue(authString.getBytes("UTF-8")).getStringValue();
      conn.addRequestProperty("Authorization", "Basic " + auth64);
    }
    
    Trace.info("Opening URL '" + url.toString() + "'");
    
    return conn.getInputStream();
  }
}
