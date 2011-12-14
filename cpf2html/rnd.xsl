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
  <xsl:param name="facet-entityType"/>
  <xsl:param name="recordId-merge"/>
  <xsl:param name="recordId-eac-merge"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="not($rmode)">
        <xsl:variable name="rnd" select="round(number(/crossQueryResult/@totalDocs) * math:random())"/>
        <xsl:variable name="limit"><xsl:value-of 
                                         select="if ($facet-entityType) then concat('&amp;facet-entityType=',$facet-entityType)
                                         else if ($recordId-merge eq 'true') then '&amp;recordId-merge=true'
                                         else if ($recordId-eac-merge eq 'true') then '&amp;recordId-eac-merge=true'
                                         else ''" />
        </xsl:variable>
        <redirect:send url="/xtf/search?mode=rnd&amp;rmode={$rnd}{$limit}"
                xsl:extension-element-prefixes="redirect" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="docId" select="replace(crossQueryResult/docHit/@path,'^default:','')"/>
        <redirect:send url="/xtf/view?docId={$docId}" xsl:extension-element-prefixes="redirect" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
