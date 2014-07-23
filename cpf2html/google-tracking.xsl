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
    <xsl:variable name="ua-code" select="document('UA-code.xml')/UA"/>
    <xsl:if test="$ua-code">
    <script type="text/javascript">
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '<xsl:value-of select="$ua-code"/>', 'virginia.edu');
  ga('require', 'linkid', 'linkid.js');
  ga('require', 'displayfeatures');
  ga('set', 'anonymizeIp', true);
  ga('send', 'pageview');
    </script>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

