
<!--
   Copyright (c) 2004, Regents of the University of California
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


<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:cdl="http://www.cdlib.org">

  <xsl:param name="bnum" select="/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type='LOCAL']"/>

  <xsl:param name="icon.path" select="concat($serverURL, 'xtf/icons/oac/')"/>

  <xsl:param name="css.path" select="concat($serverURL, 'xtf/css/oac/')"/>

  <xsl:param name="content.css" select="'content.css'"/>

  <xsl:param name="fig.ent" select="'0'"/>

  <xsl:param name="formula.id" select="'0'"/>
  
  <xsl:param name="doc.title" select="/TEI.2/text/front/titlePage//titlePart[@type='main']"/>

  <xsl:param name="doc.subtitle" select="/TEI.2/text/front/titlePage//titlePart[@type='subtitle']"/>

  <xsl:param name="doc.author">
    <xsl:choose>
      <xsl:when test="/TEI.2/text/front/titlePage/docAuthor[1]/name">
        <xsl:value-of select="/TEI.2/text/front/titlePage/docAuthor[1]/name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/TEI.2/text/front/titlePage/docAuthor[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

</xsl:stylesheet>
