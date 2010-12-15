<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:iso="iso:/3166"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all" 
  version="2.0"
  xmlns:redirect="java:/org.cdlib.xtf.saxonExt.Redirect"
  xmlns:math="java:java.lang.Math">

  <xsl:param name="rmode"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$rmode">
        <xsl:variable name="file" 
          select="replace(crossQueryResult/docHit/@path,'^default:','')"/>
          <redirect:send 
            url="/xtf/view?docId={$file}" 
            xsl:extension-element-prefixes="redirect" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable 
          name="rnd" 
          select="round(number(/crossQueryResult/@totalDocs) * math:random())" 
        />
        <redirect:send url="/xtf/search?mode=rnd&amp;rmode={$rnd}" xsl:extension-element-prefixes="redirect" />
      </xsl:otherwise>
    </xsl:choose>
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
