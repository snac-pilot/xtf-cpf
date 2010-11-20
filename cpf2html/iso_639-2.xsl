<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:iso="iso:/3166"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all" 
  version="2.0">

<xsl:variable name="isoLangData" select="document('iso_639-2_list.xml')"/>

<xsl:function name="iso:langLookup">
  <xsl:param name="in" as="xs:string"/>
  <xsl:variable name="match" select="($isoLangData)/langlist/langpair[@code=lower-case($in)]/langeng"/> 
<xsl:value-of select="if ($match) then ($match) else ($in)"/>
<!--
<langlist>
        <langpair code="aar">
                <langeng>Afar</langeng>
                <langfre>afar</langfre>

-->

</xsl:function>

</xsl:stylesheet>
