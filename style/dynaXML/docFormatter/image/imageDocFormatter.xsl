<xsl:stylesheet version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns:local="http://local"
   xmlns:saxon="http://saxon.sf.net/"
   xmlns:mets="http://www.loc.gov/METS/"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:pipe="java:/org.cdlib.xtf.saxonExt.Pipe"
   xmlns="http://www.w3.org/1999/xhtml"
   extension-element-prefixes="session pipe"
   exclude-result-prefixes="#all">
   
   <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
   <!-- BookReader dynaXML Stylesheet                                          -->
   <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
   
   <!--
      Copyright (c) 2010, Regents of the University of California
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without 
      modification, are permitted provided that the following conditions are 
      met:
      
      - Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
      - Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
      - Neither the name of the University of California nor the names of its
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.
      
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
      ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
      LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
      CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
      SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
      INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
      CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
      ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
      POSSIBILITY OF SUCH DAMAGE.
   -->
   
   <!-- 
      NOTE: This is a stab at providing XTF access to scanned books, using the
      Open Library BookReader.
   -->
   
   <!-- ====================================================================== -->
   <!-- Import Common Templates                                                -->
   <!-- ====================================================================== -->
   
   <xsl:import href="../common/docFormatterCommon.xsl"/>
   <xsl:import href="../../../xtfCommon/xtfCommon.xsl"/>
   
   <!-- ====================================================================== -->
   <!-- Output Format                                                          -->
   <!-- ====================================================================== -->
   
   <xsl:output method="xhtml" indent="yes" 
      encoding="UTF-8" media-type="text/html; charset=UTF-8" 
      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
      exclude-result-prefixes="#all"
      omit-xml-declaration="yes"/>
   
   <!-- ====================================================================== -->
   <!-- Strip Space                                                            -->
   <!-- ====================================================================== -->
   
   <xsl:strip-space elements="*"/>
   
   <!-- ====================================================================== -->
   <!-- Included Stylesheets                                                   -->
   <!-- ====================================================================== -->
   
   <xsl:include href="search.xsl"/>
   
   <!-- ====================================================================== -->
   <!-- Define Parameters                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:param name="root.URL"/>
   <xsl:param name="doc.title" select="/xtf-converted-book/xtf:meta/title"/>
   <xsl:param name="servlet.dir"/>
   <!-- for docFormatterCommon.xsl -->
   <xsl:param name="css.path" select="'css/default/'"/>
   <xsl:param name="icon.path" select="'css/default/'"/>
   <!-- image name -->
   <xsl:variable name="refPath" select="concat('/xtf/data/',replace($docId,'/[^/]+$',''),'/files/',$root,'.medium.jpg')"/>
   <!-- for image viewer -->
   <xsl:variable name="root" select="replace(replace($docId,'.+/',''),'.dc.xml','')"/>
   <xsl:variable name="root2" select="replace($root, 'id=ark:.*%2F', '')"/>
   <xsl:variable name="imagePath" select="
      concat($root.URL, 'data/13030/', substring($root2, 9, 2), '/', $root2,
      '/files/_images/',$root2)"/>
   
   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->
   
   <xsl:template match="/">
      <xsl:choose>
         <!-- robot solution -->
         <xsl:when test="matches($http.user-agent,$robots)">
            <xsl:call-template name="robot"/>
         </xsl:when>
         <xsl:when test="$doc.view='citation'">
            <xsl:call-template name="citation"/>
         </xsl:when>
         <xsl:when test="$doc.view='thumbnail'">
            <xsl:call-template name="thumbnail"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="content"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Content Template                                                       -->
   <!-- ====================================================================== -->
   
   <xsl:template name="content">
      
      <html xml:lang="en" lang="en">
         <head>
            <title>
               <xsl:value-of select="$doc.title"/>
            </title>
            <link rel="stylesheet" type="text/css" href="{$root.URL}css/default/image.css"/>
            <link rel="shortcut icon" href="icons/default/favicon.ico" />
         </head>
         <body>
            
            <xsl:variable name="pHeight" select="if ($doc.view='print') then '910' else '675'"/>
            
            
            <xsl:call-template name="translate">
               <xsl:with-param name="resultTree">
                  
                  <div class="wrapper">
                     
                     <!-- header -->
                     <xsl:copy-of select="$brand.header"/>
                     
                     <div class="nav">
                        <table width="100%">
                           <tr>
                              <xsl:choose>
                                 <xsl:when test="$doc.view='print'">
                                    <td class="left"><form><input type="button" value=" Return to Image View " onclick="window.location.href='/xtf/view?docId={$docId}';return false;" /></form></td>
                                    <td class="right"><form><input type="button" value=" Print this page " onclick="window.print();return false;" /></form></td>
                                 </xsl:when>
                                 <xsl:otherwise>
                                    <td align="left">
                                       <a href="{$root.URL}search">Home</a> | 
                                       <a href="{session:getData('queryURL')}">Return to Search Results</a></td>
                                    <td align="center">
                                       <form action="{$xtfURL}{$dynaxmlPath}" target="_top" method="get">
                                          <input name="query" type="text" size="15"/>
                                          <input type="hidden" name="docId" value="{$docId}"/>
                                          <input type="hidden" name="chunk.id" value="{$chunk.id}"/>
                                          <input type="submit" value="Search this Item"/>
                                       </form>
                                    </td>
                                    <td align="right">
                                       <a>
                                          <xsl:attribute name="href">javascript://</xsl:attribute>
                                          <xsl:attribute name="onclick">
                                             <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$xtfURL"/><xsl:value-of select="$dynaxmlPath"/><xsl:text>?docId=</xsl:text><xsl:value-of
                                                select="$docId"/><xsl:text>;doc.view=citation</xsl:text><xsl:text>','popup','width=800,height=400,resizable=yes,scrollbars=no')</xsl:text>
                                          </xsl:attribute>
                                          <xsl:text>Citation</xsl:text>
                                       </a> |
                                       <a href="/xtf/view?docId={$docId};doc.view=print">Print View</a> | 
                                       <a href="javascript://" onclick="javascript:window.open('/xtf/search?smode=getLang','popup','width=500,height=200,resizable=no,scrollbars=no')">Choose Language</a>
                                    </td>
                                 </xsl:otherwise>
                              </xsl:choose>
                           </tr>
                        </table>
                     </div>
                     
                     <div class="content">
                        <div class="meta">
                           <p><b>Author:</b>&#160;<xsl:apply-templates select="/(dc|qdc)/creator"/></p>
                           <p><b>Title:</b>&#160;<xsl:apply-templates select="/(dc|qdc)/title"/></p>
                           <p><b>Description:</b>&#160;<xsl:apply-templates select="/(dc|qdc)/description"/></p>
                           <p><b>Location:</b>&#160;<xsl:apply-templates select="/(dc|qdc)/coverage"/></p>
                           <p><b>Date:</b>&#160;<xsl:apply-templates select="/(dc|qdc)/date"/></p>
                           <p><b>Subject(s):</b><br/><xsl:for-each select="/(dc|qdc)/subject"><xsl:apply-templates select="."/><br/></xsl:for-each></p>
                        </div>
                        
                        <xsl:choose>
                           <xsl:when test="$doc.view='print'">
                              <div class="print">
                                 <img src="{$refPath}" border="0"/>
                              </div>
                           </xsl:when>
                           <xsl:otherwise>
                              <div class="viewer">
                                 <!-- image viewer -->
                                 <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" 
                                    codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" 
                                    width="100%" height="95%" 
                                    align="left">
                                    <param name="allowScriptAccess" value="sameDomain" />
                                    <param name="movie" value="/script/viewer.swf?image={$imagePath}" />
                                    <param name="quality" value="high" />
                                    <param name="scale" value="noscale" />
                                    <param name="salign" value="lt" />
                                    <param name="bgcolor" value="#ffffff" />
                                    <xsl:message>
                                       imagePath: <xsl:value-of select="$imagePath"/>
                                    </xsl:message>
                                    <embed src="{concat($root.URL, '/script/viewer.swf?image=', $imagePath)}"
                                       quality="high" 
                                       scale="noscale" salign="lt" bgcolor="#ffffff" width="100%" 
                                       height="95%" align="left" allowscriptaccess="sameDomain" 
                                       type="application/x-shockwave-flash" 
                                       pluginspage="http://www.macromedia.com/go/getflashplayer" />
                                 </object>
                              </div>
                           </xsl:otherwise>
                        </xsl:choose>
                     </div>
                  </div>
               </xsl:with-param>
            </xsl:call-template>
         </body>
      </html>
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Citation Template                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:template name="citation">
      
      <html xml:lang="en" lang="en">
         <head>
            <title>
               <xsl:value-of select="$doc.title"/>
            </title>
            <link rel="stylesheet" type="text/css" href="{$css.path}bbar.css"/>
            <link rel="shortcut icon" href="icons/default/favicon.ico" />
            
         </head>
         <body>
            <xsl:copy-of select="$brand.header"/>
            <div class="container">
               <h2>Citation</h2>
               <div class="citation">
                  <p><xsl:value-of select="/*/*:meta/*:creator[1]"/>. 
                     <xsl:value-of select="/*/*:meta/*:title[1]"/>. 
                     <xsl:value-of select="/*/*:meta/*:year[1]"/>.<br/>
                     [<xsl:value-of select="concat($xtfURL,$dynaxmlPath,'?docId=',$docId)"/>]</p>
                  <a>
                     <xsl:attribute name="href">javascript://</xsl:attribute>
                     <xsl:attribute name="onClick">
                        <xsl:text>javascript:window.close('popup')</xsl:text>
                     </xsl:attribute>
                     <span class="down1">Close this Window</span>
                  </a>
               </div>
            </div>
         </body>
      </html>
      
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Thumbnail Template                                                     -->
   <!-- ====================================================================== -->
   
   <xsl:template name="thumbnail">
      <xsl:variable name="metsPath" select="replace(saxon:system-id(), '.dc.xml', '.mets.xml')"/>
      <xsl:variable name="metsDoc" select="document($metsPath)"/>
      <xsl:variable name="cdlThumbPath" select="$metsDoc//mets:fileSec/mets:fileGrp[@USE='thumbnail image']/mets:file/mets:FLocat[1]/@xlink:href"/>
      <xsl:variable name="thumbFile" select="replace($cdlThumbPath, '.*/files/', 'files/')"/>
      <xsl:variable name="objDir" select="replace(saxon:system-id(), '[^/]+$', '')"/>
      <pipe:pipeFile path="{concat($objDir, $thumbFile)}" mimeType=""/>
   </xsl:template>
      
</xsl:stylesheet>
