<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  exclude-result-prefixes="#all" 
  version="2.0">

  <!-- preFilter for eac-cpf in XTF -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- Root Template --> 
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="get-meta"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- add metadata to XTF index -->
  <xsl:template name="get-meta">
    <xtf:meta>
      <xsl:apply-templates select="/eac:eac-cpf" mode="main-facet"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:identity" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:cpfRelation" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:resourceRelation" mode="meta"/>
    </xtf:meta>
  </xsl:template>

  <xsl:template match="eac:eac-cpf" mode="main-facet">
    <facet-recordLevel xtf:facet="yes" xtf:meta="yes">
      <xsl:choose>
        <xsl:when test="eac:cpfDescription/eac:description">
          <xsl:text>hasDescription</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>sparse</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </facet-recordLevel>
  </xsl:template>

  <xsl:template match="eac:identity" mode="meta">
    <identity xtf:meta="yes">
      <xsl:value-of select="eac:nameEntry/eac:part"/>
    </identity>
    <xsl:element name="facet-{eac:entityType}">
      <xsl:attribute name="xtf:meta">yes</xsl:attribute>
      <xsl:attribute name="xtf:facet">yes</xsl:attribute>
      <xsl:value-of select="eac:nameEntry/eac:part"/>
    </xsl:element>
  </xsl:template>
 
  <xsl:template match="eac:occupation" mode="meta">
    <occupation xtf:meta="yes"><xsl:value-of select="eac:term"/></occupation>
    <facet-occupation xtf:facet="yes" xtf:meta="yes"><xsl:value-of select="eac:term"/></facet-occupation>
  </xsl:template>

  <xsl:template match="eac:localDescription" mode="meta">
    <localDescription xtf:meta="yes"><xsl:value-of select="eac:term"/></localDescription>
    <facet-localDescription xtf:facet="yes" xtf:meta="yes"><xsl:value-of select="eac:term"/></facet-localDescription>
  </xsl:template>
  
  <xsl:template match="eac:cpfRelation" mode="meta">
    <facet-cpfRelation xtf:facet="yes" xtf:meta="yes"><xsl:value-of select="eac:relationEntry"/></facet-cpfRelation>
  </xsl:template>
  
  <xsl:template match="eac:resourceRelation" mode="meta">
    <facet-resourceRelation xtf:facet="yes" xtf:meta="yes"><xsl:value-of select="eac:relationEntry"/></facet-resourceRelation>
  </xsl:template>

  <!-- identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
   
</xsl:stylesheet>
<!--

Copyright (c) 2010, Regents of the University of California
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
- Neither the name of the University of California nor the names of its
  contributors may be used to endorse or promote products derived from this 
  software without specific prior written permission.

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
