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
  exclude-result-prefixes="#all"
  xmlns:iso="iso:/3166"
  version="2.0">

<!-- 
uses the golden grid http://code.google.com/p/the-golden-grid/

uses the Style-free XSLT Style Sheets style documented by Eric van
der Vlist July 26, 2000 http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html

xmlns:tmpl="xslt://template" attributes are used in the HTML template to indicate
tranformed elements

-->

  <xsl:include href="iso_3166.xsl"/>
  <!-- xsl:import href="xmlverbatim-xsl/xmlverbatim.xsl"/ -->
  <xsl:include href="google-tracking.xsl"/>

  <xsl:strip-space elements="*"/>

   <xsl:output method="xhtml" indent="yes" 
      encoding="UTF-8" media-type="text/html; charset=UTF-8" 
      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
      omit-xml-declaration="yes"
      exclude-result-prefixes="#all"/>
  

  <!-- options -->
  <xsl:param name="showXML"/>
  <xsl:param name="docId"/>
  <xsl:param name="mode"/>

  <!-- in dynaXML-config put
	<spreadsheets formkey="XXXX"/>
	and the "report issue" link will turn on
  -->
  <xsl:variable name="spreadsheets.code" select="document('spreadsheets-code.xml')/spreadsheets/@formkey" />
  <xsl:param name="spreadsheets.formkey" select="$spreadsheets.code"/>

  <xsl:param name="http.URL"/>
  <xsl:variable name="rel.URL" select="replace($http.URL,'http://[^/]*/','/')"/>


  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document(
    if ($mode='dracula') 
    then 'dracula-rexster.html' 
    else if( $mode='RGraph')
    then 'snac-jit.html' 
    else 'html-template.html'
  )"/>
  <xsl:variable name="footer" select="document('footer.html')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*[local-name()='html']"/>
  </xsl:template>

  <xsl:template match="link[@rel='alternate'][@type='application/rdf+xml']">
    <xsl:variable name="LOD_URI">
      <xsl:text>http://socialarchive.iath.virginia.edu/xtf/view?docId=</xsl:text>
      <xsl:value-of select="replace(escape-html-uri($docId),'\s','+')"/>
      <xsl:text>#entity</xsl:text>
    </xsl:variable>
    <xsl:variable name="sparql_describe">
      <xsl:text>http://socialarchive.iath.virginia.edu//sparql/eac?query=DESCRIBE+%3C</xsl:text>
      <xsl:value-of select="encode-for-uri($LOD_URI)"/>
      <xsl:text>%3E%0D%0A</xsl:text>
    </xsl:variable>
    <link rel="alternate" type="application/rdf+xml" href="{$sparql_describe}"/>
  </xsl:template>

  <xsl:template match='script[@tmpl:replace="excanvas"]'>
<xsl:comment>[if IE]>
&lt;script language="javascript" type="text/javascript" src="/xtf/cpf2html/Jit/Extras/excanvas.js">
&lt;/script>&lt;![endif]</xsl:comment>
  </xsl:template>

  <xsl:template match='script[@tmpl:replace="identity-script"]'>
<script>
<xsl:text>var identity = "</xsl:text>
<xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
<xsl:text>";</xsl:text>
</script>
  </xsl:template>

  <xsl:template match="*:footer">
<div class="clear">&#160;</div>
    <xsl:copy-of select="$footer"/>
    <xsl:copy-of select="document('VERSION')"/>
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

  <xsl:template match='*[@tmpl:change-value="actions"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <div><a href="/xtf/view?mode=RGraph&amp;docId={escape-html-uri($docId)}">radial graph demo</a></div>
      <xsl:if test="$spreadsheets.formkey!=''">
        <div><a title="form in new window/tab" target="_blank" href="http://spreadsheets.google.com/viewform?formkey={$spreadsheets.formkey}&amp;entry_0={encode-for-uri($http.URL)}">note data issue</a></div>
      </xsl:if>
      <a title="raw XML" href="/xtf/data/{escape-html-uri($docId)}">view source EAC-CPF</a>
      <!-- div><a href="/xtf/search?mode=rnd">random record</a></div -->
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="nameEntry-part"]'>
    <xsl:element name="{name()}">
      <span title="authorized form of name" class="{($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
      </span>
      <xsl:text> </xsl:text>
    <xsl:apply-templates select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:authorizedForm" mode="extra-names"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="extra-names"]'>
    <xsl:variable 
      name="extra-names" 
      select="($page)/eac:eac-cpf/meta/identity[position()>1][not(.=preceding::identity)]"
      xmlns=""/>
    <xsl:if test="$extra-names">
      <xsl:element name="{name()}">
        <xsl:attribute name="title" select="'alternative forms of name'"/>
        <xsl:attribute name="class" select="'extra-names'"/>
        <xsl:apply-templates select="$extra-names" mode="extra-names"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="identity" mode="extra-names">
    <xsl:text>
</xsl:text>
    <div>
      <xsl:value-of select="."/>
    </div>
  </xsl:template>

  <xsl:template match="eac:authorizedForm" mode="extra-names">
    <xsl:text> </xsl:text>
    <span title="authority" class="authorizedForm"><xsl:apply-templates mode="eac"/></span>
  </xsl:template>

  <xsl:template match="eac:nameEntry" mode="extra-names">
    <xsl:text>
</xsl:text>
    <div>
      <xsl:apply-templates select="eac:part, eac:authorizedForm" mode="extra-names"/>
    </div>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="entityId"]'>
    <xsl:variable name="entityId" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityId"/>
    <xsl:if test="$entityId">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="$entityId"/>
    </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="dateRange"]'><!-- plus VIAF gender nationality; languages Used -->
    <xsl:variable name="existDates" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:existDates"/>

    <xsl:choose>
      <xsl:when test="$existDates">
        <xsl:element name="{name()}">
          <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
          <xsl:apply-templates select="$existDates" mode="eac"/>
        <xsl:apply-templates select="
          ($page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[@localType='VIAF:gender']),
          ($page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[@localType='VIAF:nationality'])" 
          mode="viaf-extra" />
        <xsl:apply-templates select="$page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:languageUsed" mode="viaf-extra"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="placeholder">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template match="eac:localDescription[@localType='VIAF:nationality']" mode="viaf-extra">
    <span title="nationality" class="nationality"><xsl:apply-templates select="eac:placeEntry" mode="eac"/>&#160;</span>
  </xsl:template>

  <xsl:template match="eac:localDescription[@localType='VIAF:gender']" mode="viaf-extra">
    <span title="gender" class="gender"><xsl:apply-templates mode="eac"/>&#160;</span>
  </xsl:template>

  <xsl:template match="eac:languageUsed" mode="viaf-extra">
    <span title="language used" class="languageUsed"><xsl:apply-templates mode="eac"/>&#160;</span>
  </xsl:template>

  <!-- continuation template for conditional sections -->
  <xsl:template name="keep-going">
    <xsl:param name="node"/>
    <xsl:element name="{name($node)}">
      <xsl:for-each select="$node/@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:apply-templates select="($node)/*|($node)/text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="placeholder">
    <xsl:param name="node"/>
    <xsl:element name="{name($node)}">
      <xsl:for-each select="$node/@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:attribute name="class" select="'placeholder'"/>
&#160;
    </xsl:element>
  </xsl:template>

  <xsl:variable name="description" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description[eac:occupation|eac:localDescription|eac:legalStatus|eac:function|eac:occupation|eac:mandate|eac:structureOrGenealogy|eac:generalContext|eac:biogHist]"/>
  <xsl:template match='*[@tmpl:condition="description"]'>
    <xsl:choose>
      <xsl:when test="($description)">
        <xsl:call-template name="keep-going">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="placeholder">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="occupations" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations 
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupation"/>

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

  <xsl:variable name="localDescriptions" select="
          ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[not(starts-with(@localType,'VIAF'))]"/>

  <xsl:template match='*[@tmpl:condition="localDescriptions"]'>
    <xsl:if test="($localDescriptions)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($localDescriptions)">
      <xsl:call-template name="placeholder">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="localDescriptions"]'>
    <xsl:apply-templates select="$localDescriptions" mode="eac"/>
  </xsl:template>

  <xsl:variable name="places" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:places
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:place"/>

  <xsl:template match='*[@tmpl:condition="places"]'>
    <xsl:if test="($places)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="places"]'>
    <xsl:apply-templates select="$places" mode="eac"/>
  </xsl:template>

  <xsl:variable name="functions" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:function"/>

  <xsl:template match='*[@tmpl:condition="functions"]'>
    <xsl:if test="($functions)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="functions"]'>
    <xsl:apply-templates select="$functions" mode="eac"/>
  </xsl:template>

  <xsl:variable name="mandates" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandate"/>

  <xsl:template match='*[@tmpl:condition="mandates"]'>
    <xsl:if test="($mandates)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="mandates"]'>
    <xsl:apply-templates select="$mandates" mode="eac"/>
  </xsl:template>

  <xsl:variable name="biogHist" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:biogHist"/>

  <xsl:template match='*[@tmpl:condition="biogHist"]'>
    <xsl:if test="($biogHist)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($biogHist)">
      <xsl:call-template name="placeholder">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="biogHist"]'>
    <!-- contain div is to get :first-child to work -->
    <div><xsl:apply-templates select="$biogHist" mode="eac"/></div>
  </xsl:template>

  <xsl:variable name="generalContext" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext"/>

  <xsl:template match='*[@tmpl:condition="generalContext"]'>
    <xsl:if test="($generalContext)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="generalContext"]'>
    <xsl:apply-templates select="$generalContext" mode="eac"/>
  </xsl:template>

  <xsl:variable name="relations" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:relations"/>

  <xsl:template match="*[@tmpl:replace-markup='sameAs']" name="sameAs">
    <xsl:variable name="VIAF" select="($page)/eac:eac-cpf/eac:control/eac:sources/eac:source[starts-with(@xlink:href,'VIAF:')]"/>
    <xsl:variable name="viafUrl" select="replace($VIAF/@xlink:href,'^VIAF:(.*)$','viaf.org/viaf/$1')"/>
    <xsl:variable name="dbpedia" select="($page)/eac:eac-cpf/eac:control/eac:otherRecordId[@localType='dbpedia']"/>
    <xsl:variable name="dbpediaUrl" select="replace($dbpedia,'^dbpedia:(.*)$','$1')"/>
    <xsl:variable name="wikipedia" select="replace($dbpedia, '^http://dbpedia.org/resource/', 'http://en.wikipedia.org/wiki/')"/>
    <xsl:if test="$VIAF or $dbpedia">
      <h3><span><a href="#">Linked Data (<xsl:value-of select="count($VIAF) + count($dbpedia)"/>)</a></span></h3>
      <div>
        <xsl:if test="$VIAF">
          <div class="related" about="http://socialarchive.iath.virginia.edu/xtf/view?docId={replace(escape-html-uri($docId),'\s','+')}#entity">
            <div class="arcrole">sameAs</div>
              <a xmlns:owl="http://www.w3.org/2002/07/owl#" 
                  rel="owl:sameAs" 
                  title="Virtual International Authority File" 
                  href="http://{$viafUrl}">http://<xsl:value-of select="$viafUrl"/></a>
          </div>
        </xsl:if>
        <xsl:if test="$dbpedia">
          <div class="related" about="http://socialarchive.iath.virginia.edu/xtf/view?docId={replace(escape-html-uri($docId),'\s','+')}#entity">
            <div class="arcrole">sameAs</div>
              <a xmlns:owl="http://www.w3.org/2002/07/owl#" 
                  rel="owl:sameAs" 
                  title="DBpedia" 
                  href="{$dbpediaUrl}"><xsl:value-of select="$dbpediaUrl"/></a>
          </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match='*[@tmpl:condition="relations"]'>
    <xsl:if test="($relations)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="relations"]'>
   <div>
    <xsl:variable name="archivalRecords" select="($relations)/eac:resourceRelation[starts-with(@xlink:role,'archival')]" />
    <xsl:variable name="archivalRecords-creatorOf" select="($archivalRecords)[contains(@xlink:arcrole, 'creatorOf')]"/>
    <xsl:variable name="archivalRecords-referencedIn" select="($archivalRecords)[not(contains(@xlink:arcrole, 'creatorOf'))]"/>


    <xsl:if test="$archivalRecords">
        <h3><span><a href="#">Archival Records (<xsl:value-of select="count($archivalRecords)"/>)</a></span></h3>
<div>
  <ul>
    <xsl:if test="$archivalRecords-creatorOf">
      <li><a href="#creatorOf">creatorOf (<xsl:value-of select="count($archivalRecords-creatorOf)"/>)</a></li>
    </xsl:if>
    <xsl:if test="$archivalRecords-referencedIn">
      <li><a href="#referencedIn">referencedIn (<xsl:value-of select="count($archivalRecords-referencedIn)"/>)</a></li>
    </xsl:if>
  </ul>
  <div id="creatorOf">
        <xsl:apply-templates select="($archivalRecords-creatorOf)" mode="eac">
          <xsl:sort select="eac:relationEntry"/>
        </xsl:apply-templates>
  </div>
  <div id="referencedIn">
        <xsl:apply-templates select="($archivalRecords-referencedIn)" mode="eac">
          <xsl:sort select="eac:relationEntry"/>
        </xsl:apply-templates>
  </div>
</div>
    </xsl:if>
    <xsl:apply-templates select="$relations| ($relations)/*[eac:cpfRelation]" mode="eac">
      <xsl:sort select="eac:relationEntry"/>
    </xsl:apply-templates>
    <xsl:call-template name="sameAs"/>
   </div>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="google-tracking-code"]'>
    <xsl:call-template name="google-tracking-code"/>
<xsl:text disable-output-escaping="yes">
<![CDATA[
<!--[if lt IE 9]>
<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
]]>
</xsl:text>
  </xsl:template>

  <!-- templates that format EAC to HTML -->

  <xsl:template match="eac:existDates" mode="eac">
    <xsl:apply-templates select="eac:dateRange" mode="eac"/>
  </xsl:template>

  <xsl:template match="eac:dateRange" mode="eac">
    <time title="life dates">
    <xsl:value-of select="@localType"/>
    <xsl:value-of select="eac:fromDate"/>
    <xsl:text> - </xsl:text>
    <xsl:value-of select="@localType"/>
    <xsl:value-of select="eac:toDate"/>
    </time>
  </xsl:template>

  <xsl:template match="eac:occupations | eac:localDescriptions | eac:functions | eac:mandates | eac:places" mode="eac">
    <xsl:if test="eac:occupation | eac:localDescription | eac:function | eac:mandate | eac:place">
      <ul>
        <xsl:apply-templates select="eac:occupation | eac:localDescription | eac:function | eac:mandate | eac:place" mode="eac-inlist"/>
      </ul>
    </xsl:if>
    <xsl:apply-templates select="eac:descriptiveNote| eac:p" mode="eac"/>
  </xsl:template>

  <xsl:template match="eac:function | eac:mandate | eac:place" mode="eac-inlist">
    <li><xsl:apply-templates mode="eac"/></li>
  </xsl:template>

  <!-- xsl:template match="eac:occupation | eac:function | eac:mandate | eac:place" mode="eac-inlist">
    <li>
      <xsl:apply-templates select="@localType[.!='subject']"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates mode="eac"/>
    </li>
  </xsl:template -->

  <xsl:template match="eac:occupation" mode="eac-inlist">
    <xsl:variable name="value">
      <xsl:apply-templates mode="eac"/>
    </xsl:variable>
    <xsl:variable name="normalValue" 
      select="replace(replace(normalize-space(.)
      ,'[^\w\)]+$','')
      ,'--.*$','')
    "/>
    <xsl:variable name="href">
      <xsl:text>/xtf/search?sectionType=cpfdescription&amp;f1-occupation=</xsl:text>
      <xsl:value-of select="$normalValue"/>
      <xsl:if test="matches($value,'--.*')">
        <xsl:text>&amp;text=</xsl:text>
        <xsl:value-of select="normalize-space($value)"/>
      </xsl:if>
    </xsl:variable>
    <li>
      <a href="{$href}">
        <xsl:value-of select="replace($value,'--','-&#173;-')"/>
      </a>
    </li>
  </xsl:template>

  <xsl:template match="eac:localDescription" mode="eac-inlist">
    <xsl:variable name="value">
      <!-- xsl:apply-templates select="@localType[.!='subject']"/>
      <xsl:text> </xsl:text -->
      <xsl:apply-templates mode="eac"/>
    </xsl:variable>
    <xsl:variable name="normalValue" 
      select="replace(replace(replace(normalize-space(.)
      ,'[^\w\)]+$','')
      ,'--.*$','')
      ,'^VIAF:','')
    "/>
    <xsl:variable name="href">
      <xsl:text>/xtf/search?sectionType=cpfdescription&amp;f1-localDescription=</xsl:text>
      <xsl:value-of select="normalize-space($normalValue)"/>
      <xsl:if test="matches($value,'--.*')">
        <xsl:text>&amp;text=</xsl:text>
        <xsl:value-of select="replace(normalize-space($value),'^VIAF:','')"/>
      </xsl:if>
    </xsl:variable>
    <li>
      <a href="{$href}">
        <xsl:value-of select="replace(replace($value,'^VIAF:',''),'--','-&#173;-')"/>
      </a>
    </li>
  </xsl:template>

  <xsl:template match="eac:localDescription[not(starts-with(@localType,'VIAF'))] | eac:occupation | eac:function | eac:mandate | eac:place" mode="eac">
    <ul>
      <xsl:apply-templates select="." mode="eac-inlist"/>
    </ul>
  </xsl:template>

  <xsl:template match="eac:biogHist" mode="eac">
   <div class="biogHist"><xsl:apply-templates mode="eac"/></div>
  </xsl:template>

  <xsl:template match="eac:chronList" mode="eac">
    <div class="{local-name()}"><xsl:apply-templates select="eac:chronItem" mode="eac"/></div>
  </xsl:template>

  <xsl:template match="eac:p" mode="eac">
    <p><xsl:apply-templates mode="eac"/></p>
  </xsl:template>

  <xsl:template match="eac:list" mode="eac">
    <ul><xsl:apply-templates mode="eac"/></ul>
  </xsl:template>

  <xsl:template match="eac:item" mode="eac">
    <li><xsl:apply-templates mode="eac"/></li>
  </xsl:template>

  <xsl:template match="eac:citation" mode="eac">
    <small><xsl:apply-templates mode="eac"/></small>
  </xsl:template>

  <xsl:template match="eac:chronItem" mode="eac">
    <div itemscope="itemscope">
      <xsl:apply-templates select="eac:date|eac:dateRange" mode="eac"/>
      <xsl:apply-templates select="eac:placeEntry|eac:event" mode="eac"/>
    </div>
  </xsl:template>

  <xsl:template match="eac:placeEntry[parent::eac:localDescription[@localType='VIAF:nationality']]" mode="eac">
    <xsl:value-of select="iso:lookup(@countryCode)"/>
  </xsl:template>

  <xsl:template match="eac:event[parent::eac:chronItem]|eac:placeEntry[parent::eac:chronItem]" mode="eac">
    <div itemprop="{local-name()}"><xsl:apply-templates mode="eac"/></div>
  </xsl:template>

  <xsl:template match="eac:date[parent::eac:chronItem]|eac:dateRange[parent::eac:chronItem]" mode="eac">
    <time itemprop="{local-name()}"><xsl:apply-templates mode="eac"/></time>
  </xsl:template>

  <xsl:template match="eac:relations" mode="eac">
    <xsl:variable name="people" select="eac:cpfRelation[ends-with(lower-case(@xlink:role),'person') or @cpfRelationType='family']"/>
    <xsl:if test="$people">
      <h3><span><a href="#">People (<xsl:value-of select="count($people)"/>)</a></span></h3>
      <div>
        <xsl:apply-templates select="$people" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
    <xsl:variable name="corporateBodies" select="eac:cpfRelation[ends-with(lower-case(@xlink:role),'corporatebody') or @cpfRelationType='associative']">
    </xsl:variable>
    <xsl:if test="$corporateBodies">
      <h3><span><a href="#">Corporate Bodies (<xsl:value-of select="count($corporateBodies)"/>)</a></span></h3>
      <div>
        <xsl:apply-templates select="$corporateBodies" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
    <xsl:variable name="resources" select="eac:resourceRelation[not(@xlink:role='archivalRecords')]"/>
    <xsl:if test="$resources">
      <h3><span><a href="#">Resources (<xsl:value-of select="count($resources)"/>)</a></span></h3>
      <div>
        <xsl:apply-templates select="$resources" mode="eac">
          <xsl:sort select="eac:relationEntry"/>
          <xsl:with-param name="link-mode" select="'worldcat-title'"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eac:cpfRelation | eac:resourceRelation" mode="eac">
    <xsl:param name="link-mode" select="'snac'"/>
    <div class="{if (ends-with(lower-case(@xlink:role),'person')) then ('person') 
                 else if (ends-with(lower-case(@xlink:role),'corporatebody')) then ('corporateBody')
                 else if (ends-with(lower-case(@xlink:role),'family')) then ('family')
                 else if (@cpfRelationType) then @cpfRelationType 
                 else 'related'}">
      <xsl:choose>
        <xsl:when test="@xlink:href">
          <a href="{@xlink:href}"><xsl:apply-templates select="eac:relationEntry | eac:placeEntry" mode="eac"/></a>
          <xsl:variable name="extra-info" select="eac:date | eac:dateRange | eac:dateSet | eac:objectXMLWrap/ead:did[1]/ead:repository[1]"/>
          <xsl:if test="$extra-info">
            <div>
              <xsl:apply-templates select="$extra-info" mode="eac">
                <xsl:sort/>
              </xsl:apply-templates>
            </div>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$link-mode = 'worldcat-title'">
          <a href="http://www.worldcat.org/search?q=ti:{
            encode-for-uri(eac:relationEntry)}+au:{
            encode-for-uri(($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part)}"
          >
            <xsl:value-of select="eac:relationEntry"/>
            <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <!-- xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/ -->
          <a href="/xtf/search?text={encode-for-uri(eac:relationEntry)};browse=">
            <xsl:value-of select="eac:relationEntry"/>
            <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
 
  <xsl:template match="@xlink:arcrole" mode="arcrole">
            <span class="arcrole"><xsl:value-of select="."/></span>
  </xsl:template>

  <xsl:template match="ead:repository" mode="eac">
    <xsl:value-of select="ead:corpname[1]"/>
  </xsl:template>

  <xsl:template match="@*" mode="attribute">
    <xsl:value-of select="name()"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="."/>
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
