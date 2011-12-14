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
    <!-- http://code.google.com/apis/analytics/docs/gaJS/gaJSApi_gaq.html -->
    <script type="text/javascript">
/*jslint nomen: false */
var _gaq = _gaq || [];
_gaq.push(['_gat._anonymizeIp'], ['snak._setAccount', '<xsl:value-of select="document('UA-code.xml')/UA"/>'], ['snak._trackPageview']);
/*jslint nomen: true */
    </script>
  </xsl:template>
</xsl:stylesheet>

