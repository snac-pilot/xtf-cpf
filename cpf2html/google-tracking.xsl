<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tmpl="xslt://template"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xtf="http://cdlib.org/xtf"
  exclude-result-prefixes="#all"
  version="2.0">
  <xsl:template name="google-tracking-code">
    <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '<xsl:value-of select="document('UA-code.xml')/UA"/>']);
      _gaq.push(['_trackPageview']);
    </script>
  </xsl:template>
</xsl:stylesheet>

