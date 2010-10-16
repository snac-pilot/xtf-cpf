<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:session="java:org.cdlib.xtf.xslt.Session"
        xmlns:editURL="http://cdlib.org/xtf/editURL"
        xmlns:tmpl="xslt://template">
  <xsl:output method="text" indent="yes" encoding="UTF-8" media-type="text/javascript"/>
  <xsl:param name="callback"/>
  <xsl:param name="term"/>

  <!--

	XTF<-> JSONP for jQuery UI autocomplete

    -->

  <xsl:template match="/">
    <!-- regex on callback parameter to sanitize user input -->
    <!-- http://www.w3.org/TR/xmlschema-2/ '\c' = the set of name characters, those ·match·ed by NameChar -->
    <xsl:value-of select="replace(replace($callback,'[^\c]',''),':','')"/>
    <xsl:text>([</xsl:text>
    <xsl:apply-templates select="/crossQueryResult/docHit"/>
    <xsl:text>]);</xsl:text>
  </xsl:template>

  <xsl:template match="docHit">
    <xsl:apply-templates select="meta/identity[1]"/>
    <xsl:text>,</xsl:text>
  </xsl:template>

  <xsl:template match="docHit[last()]">
    <xsl:apply-templates select="meta/identity[1]"/>
  </xsl:template>

  <xsl:template match="identity">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
