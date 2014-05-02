<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:ead="urn:isbn:1-931666-22-9"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tmpl="xslt://template" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="#all"
  xmlns:iso="iso:/3166"
  version="2.0">

  <xsl:template match="*[@data-xsl-asset]">
    <xsl:element name="{name(.)}">
      <xsl:apply-templates select="@*" mode="asset-base"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@href|@src" mode="asset-base">
    <xsl:attribute name="{name(.)}">
      <xsl:value-of select="$asset-base.value"/>
      <xsl:value-of select="../@data-xsl-asset"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*" mode="asset-base">
    <xsl:attribute name="{name(.)}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
