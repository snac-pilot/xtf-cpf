<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tmpl="xslt://template" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  exclude-result-prefixes="#all" 
  version="2.0">

  <xsl:strip-space elements="*"/>

  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document('html-template.html')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*[local-name()='html']"/>
  </xsl:template>

  <!-- templates that hook the html template to the EAC -->

  <xsl:template match='*[@tmpl:change-value="html-title"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
      <xsl:text> [</xsl:text>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityId"/>
      <xsl:text>]</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="nameEntry-part"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
    </xsl:element>
    <xsl:apply-templates select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[position()>1]" mode="extra-names"/>
  </xsl:template>

  <xsl:template match="eac:nameEntry" mode="extra-names">
    <div class="extra-names"><xsl:value-of select="eac:part"/></div>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="entityId"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityId"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="dateRange"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:apply-templates select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:existDates" mode="eac"/>
    </xsl:element>
  </xsl:template>

  <!-- continuation template for conditional sections -->
  <xsl:template name="keep-going">
    <xsl:param name="node"/>
    <xsl:element name="{name($node)}">
      <xsl:for-each select="$node/@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="($node)/*|($node)/text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:variable name="occupations" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations"/>

  <xsl:template match='*[@tmpl:condition="occupations"]'>
    <xsl:if test="($occupations)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="occupations"]'>
    <xsl:apply-templates select="$occupations" mode="eac"/>
  </xsl:template>

  <xsl:variable name="localDescriptions" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions"/>

  <xsl:template match='*[@tmpl:condition="localDescriptions"]'>
    <xsl:if test="($localDescriptions)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="localDescriptions"]'>
    <xsl:apply-templates select="$localDescriptions" mode="eac"/>
  </xsl:template>

  <xsl:variable name="biogHist" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:biogHist"/>

  <xsl:template match='*[@tmpl:condition="biogHist"]'>
    <xsl:if test="($biogHist)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="biogHist"]'>
    <xsl:apply-templates select="$biogHist" mode="eac"/>
  </xsl:template>

  <xsl:variable name="relations" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:relations"/>

  <xsl:template match='*[@tmpl:condition="relations"]'>
    <xsl:if test="($relations)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="relations"]'>
    <xsl:apply-templates select="$relations" mode="eac"/>
  </xsl:template>

  <!-- templates that format EAC to HTML -->

  <xsl:template match="eac:existDates" mode="eac">
    <xsl:value-of select="eac:dateRange/eac:fromDate"/>
    <xsl:text> - </xsl:text>
    <xsl:value-of select="eac:dateRange/eac:toDate"/>
  </xsl:template>

  <xsl:template match="eac:occupations" mode="eac">
    <ul><xsl:apply-templates select="eac:occupation" mode="eac"/></ul>
  </xsl:template>

  <xsl:template match="eac:occupation" mode="eac">
    <li><xsl:apply-templates mode="eac"/></li>
  </xsl:template>

  <xsl:template match="eac:localDescriptions" mode="eac">
    <ul><xsl:apply-templates select="eac:localDescription" mode="eac"/></ul>
  </xsl:template>

  <xsl:template match="eac:localDescription" mode="eac">
    <li><xsl:apply-templates mode="eac"/></li>
  </xsl:template>

  <xsl:template match="eac:biogHist" mode="eac">
    <div><xsl:apply-templates mode="eac"/></div>
  </xsl:template>

  <xsl:template match="eac:chronList" mode="eac">
    <dl><xsl:apply-templates select="eac:chronItem" mode="eac"/></dl>
  </xsl:template>

  <xsl:template match="eac:chronItem" mode="eac">
    <dt><xsl:apply-templates select="eac:date" mode="eac"/></dt>
    <dd><xsl:apply-templates select="eac:event" mode="eac"/></dd>
  </xsl:template>

  <xsl:template match="eac:relations" mode="eac">
    <xsl:if test="eac:cpfRelation[@xlink:role='person']"><h3>People</h3></xsl:if>
    <xsl:apply-templates select="eac:cpfRelation[@xlink:role='person']" mode="eac"/>
    <xsl:if test="eac:cpfRelation[@xlink:role='corporateBody']"><h3>Corporate Bodies</h3></xsl:if>
    <xsl:apply-templates select="eac:cpfRelation[@xlink:role='corporateBody']" mode="eac"/>
    <xsl:if test="eac:resourceRelation"><h3>Resources</h3></xsl:if>
    <xsl:apply-templates select="eac:resourceRelation" mode="eac"/>
  </xsl:template>

  <xsl:template match="eac:cpfRelation | eac:resourceRelation" mode="eac">
    <div><xsl:apply-templates mode="eac"/></div>
  </xsl:template>

  <xsl:template match="*" mode="eac">
    <xsl:apply-templates mode="eac"/>
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
