<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:iso="iso:/3166"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all" 
  version="2.0">

<xsl:variable name="data" select="document('iso_3166-1_list_en.xml')"/>

<xsl:function name="iso:lookup">
  <xsl:param name="in" as="xs:string"/>
  <xsl:variable name="match" select="($data)/ISO_3166-1_List_en/ISO_3166-1_Entry[ISO_3166-1_Alpha-2_Code_element=upper-case($in)]/ISO_3166-1_Country_name"/> 
<xsl:value-of select="if ($match) then iso:normalizeTitleContent($match) else ($in)"/>
<!--
<ISO_3166-1_List_en xml:lang="en">
   <ISO_3166-1_Entry>
      <ISO_3166-1_Country_name>AFGHANISTAN</ISO_3166-1_Country_name>
      <ISO_3166-1_Alpha-2_Code_element>AF</ISO_3166-1_Alpha-2_Code_element>
-->

</xsl:function>

<xsl:function
     name="iso:normalizeTitleContent" as="xs:string">
  <!-- http://www.biglist.com/lists/xsl-list/archives/200706/msg00078.html -->
  <!-- Normalizes the case of titles based on the 
       FASB-defined rules for title case -->
  <xsl:param name="titleElem" as="xs:string"/>
  <xsl:sequence select="
     string-join(
       for $x in tokenize(lower-case($titleElem), ' ')
         return concat(upper-case(substring($x, 1,1)), substring($x, 2)),
       ' ')"/>
</xsl:function>

</xsl:stylesheet>
