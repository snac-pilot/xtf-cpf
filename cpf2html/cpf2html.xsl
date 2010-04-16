<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tmpl="xslt://template" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

  <xsl:output method="xhtml" indent="yes" encoding="utf-8" media-type="text/html; charset=UTF-8" omit-xml-declaration="yes"/>

  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document('html-template.html')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*[local-name()='html']"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="html-title"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      CHANGEME
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="nameEntry-part"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      CHANGEME
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="entityId"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      CHANGEME
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="dateRange"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      CHANGEME
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="occupations"]'>
    <ul><li>change me</li></ul>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="localDescriptions"]'>
    <ul><li>change me</li></ul>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="biogHist"]'>
    <dl><dt>change</dt><dd>me</dd></dl>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="relations"]'>
    <h3>Change</h3>
    <div>me</div>
    <div>too</div>
  </xsl:template>

  <!-- identity transform copies HTML from the layout file -->
  <xsl:template match="*">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:element>
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
