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

<!-- 
uses the Style-free XSLT Style Sheets style documented by Eric van
der Vlist July 26, 2000 http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html

use html5 data-xsl* attributes to trigger xslt

-->

  <xsl:include href="iso_3166.xsl"/>
  <xsl:include href="google-tracking.xsl"/>

  <xsl:strip-space elements="*"/>

   <xsl:output encoding="UTF-8" media-type="text/html" indent="yes"
      method="xhtml" doctype-system="about:legacy-compat"
      omit-xml-declaration="yes"
      exclude-result-prefixes="#all"/>
  
  <xsl:param name="asset-base.value"/>
  <xsl:include href="data-xsl-asset.xsl"/>
  <xsl:param name="appBase.path"/>

  <xsl:param name="docId"/>
  <!-- poor man's ARK resolver -->
  <xsl:variable name="pathId">
    <xsl:choose>
      <xsl:when test="starts-with($docId,'ark:/')">
        <xsl:value-of select="replace(replace($docId,'ark:/',''),'/','-')"/>
        <xsl:text>.xml</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$docId"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:param name="http.URL"/><!-- XTF supplied param -->
  <xsl:variable name="rel.URL" select="replace($http.URL,'http://[^/]*/','/')"/>

  <xsl:param name="mode"/>
  <xsl:variable name="layoutDoc"/>
  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="if ($mode='old') then document('html-template.html') 
                                      else document('identity.html')"/>
  <xsl:variable name="footer" select="document('footer.html')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*:html"/>
  </xsl:template>

  <xsl:template match='script[@tmpl:replace="identity-script"]'>
<script>
<xsl:text>var identity = "</xsl:text>
<xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
<xsl:text>";</xsl:text>
</script>
  </xsl:template>

  <!-- templates that hook the html template to the EAC -->

  <xsl:template match="*[@data-xsl='wikipedia_thumbnail']">
    <xsl:variable name="wt" select="$page/eac:eac-cpf/meta/facet-wikithumb"/>
    <xsl:if test="$wt">
      <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
        <a href="{($wt)//@rights}">
          <img src="{($wt)//@thumb}" alt= "" />
          <div>Image from Wikipedia</div>
        </a>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="html-title"]|*[@data-xsl="title"]'>
    <xsl:element name="{name()}">

      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
      <xsl:text> [</xsl:text>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityId"/>
      <xsl:text>]</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="actions"]|*[@data-xsl="viewSource"]'>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <a title="raw XML" href="{$appBase.path}data/{escape-html-uri($pathId)}">View source EAC-CPF</a>
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="nameEntry-part"]|*[@data-xsl="identity"]'>
    <xsl:element name="{name()}">
      <span title="authorized form of name" class="{($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:value-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
      </span>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[@data-xsl='collection_locations']">
    <div class="modal-body">
      <xsl:apply-templates select="$page/eac:eac-cpf/meta/facet-Location" mode="eac"/>
    </div>
  </xsl:template>
  <xsl:template match="facet-Location" mode="eac">
    <div><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="extra-names"]|*[@data-xsl="alternative_names"]'>
    <xsl:variable 
      name="extra-names" 
      select="($page)/eac:eac-cpf/meta/identity[position()>1][not(.=preceding::identity)]"
      xmlns=""/>
    <xsl:if test="$extra-names">
      <xsl:element name="{name()}">
        <xsl:attribute name="title" select="'alternative forms of name'"/>
        <xsl:attribute name="class" select="'extra-names modal-body'"/>
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

  <xsl:template match="*[@data-xsl='authoritySource']">
    <xsl:variable name="ident" select="$page/eac:eac-cpf/eac:cpfDescription/eac:identity"/>
    <div data-xsl='authoritySource'>
      <label>Authority Source:</label>
      <xsl:apply-templates select="$ident/eac:nameEntry[1]/eac:authorizedForm" mode="eac"/>
    </div>
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
          <xsl:text>(</xsl:text>
          <xsl:apply-templates select="$existDates" mode="eac"/>
          <xsl:text>)</xsl:text>
        <xsl:apply-templates select="
          ($page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[@localType='http://viaf.org/viaf/terms#gender']),
          ($page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[@localType='http://viaf.org/viaf/terms#nationalityOfEntity'])" 
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

  <xsl:template match="eac:localDescription[@localType='http://viaf.org/viaf/terms#nationalityOfEntity']" mode="viaf-extra">
    <span title="nationality" class="nationality"><xsl:apply-templates select="eac:placeEntry" mode="eac"/>&#160;</span>
  </xsl:template>

  <xsl:template match="eac:localDescription[@localType='http://viaf.org/viaf/terms#gender']" mode="viaf-extra">
    <span title="gender" class="gender"><xsl:apply-templates mode="eac"/>&#160;</span>
  </xsl:template>

  <xsl:template match="eac:languageUsed" mode="viaf-extra">
    <span title="language used" class="languageUsed"><xsl:apply-templates mode="eac"/>&#160;</span>
  </xsl:template>

  <xsl:template match="*[@data-xsl='nationality']">
    <xsl:variable name="desc" select="$page/eac:eac-cpf/eac:cpfDescription/eac:description"/>
    <div data-xsl='nationality'>
      <label>Nationality: </label>
      <xsl:value-of select="$desc/eac:localDescription[@localType='http://viaf.org/viaf/terms#nationalityOfEntity']/eac:placeEntry/iso:lookup(lower-case(@countryCode))"/>
    </div>
  </xsl:template>

  <xsl:template match="*[@data-xsl='language']">
    <xsl:variable name="desc" select="$page/eac:eac-cpf/eac:cpfDescription/eac:description"/>
    <div data-xsl='language'>
      <label>Language: </label>
      <xsl:apply-templates select="$page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:languageUsed" mode="eac"/>
    </div>
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
        <xsl:copy-of select="($page)/eac:eac-cpf/eac:cpfDescription/eac:relations//img"/>
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

  <xsl:variable name="occupations"> 
    <xsl:for-each-group select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations 
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupation"
      group-by="."
    >
      <xsl:sort order="ascending" select="."/>
      <xsl:copy-of select="."/>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:template match='*[@tmpl:replace-markup="localDescriptions"]|*[@data-xsl="subjects"]'>
    <xsl:apply-templates select="$localDescriptions" mode="eac"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:condition="occupations"]'> 
    <xsl:if test="($occupations)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="occupations"]|*[@data-xsl="occupations"]'>
    <xsl:apply-templates select="$occupations" mode="eac"/>
  </xsl:template>

  <xsl:variable name="localDescriptions">
    <xsl:for-each-group 
      group-by="."
      select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description
                  //eac:localDescription
                    [not(starts-with(@localType,'http://viaf.org/viaf/terms'))]
                    [not(matches(.,'^[\d|\s|-]+$'))]
      "
    ><!-- /^\d+$/  -->
      <xsl:sort/>
      <xsl:copy-of select="."/>
    </xsl:for-each-group>
  </xsl:variable>

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
  <xsl:template match='*[@tmpl:replace-markup="biogHist"]|*[@data-xsl="bioghist"]'>
    <!-- contain div is to get :first-child to work -->
    <xsl:apply-templates select="$biogHist" mode="eac"/>
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

  <xsl:template match="*[@tmpl:replace-markup='sameAs']" name="sameAs">
    <xsl:variable name="sameAs" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:relations/*[contains(@xlink:arcrole,'#sameAs')]" />
    <xsl:if test="$sameAs">
      <h3><span><a href="#">Linked Data (<xsl:value-of select="count($sameAs)"/>)</a></span></h3>
      <div>
        <xsl:apply-templates select="$sameAs" mode="sameAs"/>
      </div>
    </xsl:if>
  </xsl:template>
  <xsl:template match="*" mode="sameAs">
    <div class="related">
      <div class="arcrole"><xsl:value-of select="@xlink:arcrole"/></div>
      <a href="{@xlink:href}">
        <xsl:value-of select="@xlink:href"/>
      </a>
    </div>
  </xsl:template>

  <xsl:variable name="relations" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:relations"/>
  <xsl:variable name="archivalRecords" select="($relations)/eac:resourceRelation[contains(lower-case(@xlink:role),'archival')]" />
  <xsl:variable name="archivalRecords-creatorOf" select="($archivalRecords)[contains(@xlink:arcrole, 'creatorOf')]"/>
  <xsl:variable name="archivalRecords-referencedIn" select="($archivalRecords)[not(contains(@xlink:arcrole, 'creatorOf'))]"/>

  <xsl:variable name="relatedWorks" select="($relations)/eac:resourceRelation[not(contains(lower-case(@xlink:role),'archival'))]"/>
  <xsl:variable name="relatedPeople">
 <!-- select="($relations)/eac:cpfRelation[ends-with(lower-case(@xlink:role),'person') or @cpfRelationType='family'][not(    contains(@xlink:arcrole,'#sameAs'))]"> -->
    <xsl:for-each-group group-by="@xlink:href"
   select="($relations)/eac:cpfRelation[ends-with(lower-case(@xlink:role),'person') or @cpfRelationType='family'][not(    contains(@xlink:arcrole,'#sameAs'))]"> 
      <xsl:sort/>
      <xsl:copy-of select="."/>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:variable name="relatedFamilies">
    <xsl:for-each-group group-by="@xlink:href"
select="($relations)/eac:cpfRelation[
            ends-with(lower-case(@xlink:role),'family')][not(ends-with(@xlink:arcrole,'#sameAs'))]">
      <xsl:sort/>
      <xsl:copy-of select="."/>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:variable name="relatedOrganizations">
    <xsl:for-each-group group-by="@xlink:href"
    select="($relations)/
      eac:cpfRelation[ends-with(lower-case(@xlink:role),'corporatebody') or @cpfRelationType='associative' ]
                     [not(ends-with(@xlink:arcrole,'#sameAs'))]
  ">
      <xsl:sort/>
      <xsl:copy-of select="."/>
    </xsl:for-each-group>
  </xsl:variable>
  <xsl:variable name="linkedData" select="($relations)/*[contains(@xlink:arcrole,'#sameAs')]"/>
  <xsl:variable name="maybeSame" select="($relations)/*[contains(@xlink:arcrole,'#mayBeSameAs')]"/>
  <!--
   data-xsl="relatedCollections"
   data-xsl="relatedWorks"
   data-xsl="relatedPeople"
   data-xsl="relatedFamilies"
   data-xsl="relatedOrganizations"
   data-xsl="linkedData"
  -->

  <xsl:template match="*[@data-xsl='linkedData']">
    <xsl:call-template name="panel">
      <xsl:with-param name="id" select="'linkedData'"/>
      <xsl:with-param name="head">
        <xsl:text>Linked Data</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="body">
        <xsl:apply-templates select="$linkedData" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="count" select="count($linkedData)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@data-xsl='relatedWorks']">
    <xsl:call-template name="panel">
      <xsl:with-param name="id" select="'relatedWorks'"/>
      <xsl:with-param name="head">
        <xsl:text>Resources</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="body">
        <xsl:apply-templates select="$relatedWorks" mode="eac">
          <xsl:sort select="eac:relationEntry"/>
          <xsl:with-param name="link-mode" select="'worldcat-title'"/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="count" select="count($relatedWorks)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@data-xsl='relatedPeople']">
    <xsl:call-template name="panel">
      <xsl:with-param name="id" select="'relatedPeople'"/>
      <xsl:with-param name="head">
        <xsl:text>People</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="body">
        <xsl:apply-templates select="$relatedPeople" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="count" select="count($relatedPeople/*)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@data-xsl='relatedFamilies']">
    <xsl:call-template name="panel">
      <xsl:with-param name="id" select="'relatedFamilies'"/>
      <xsl:with-param name="head">
        <xsl:text>Families</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="body">
        <xsl:apply-templates select="$relatedFamilies" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="count" select="count($relatedFamilies/*)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@data-xsl='relatedOrganizations']">
    <xsl:call-template name="panel">
      <xsl:with-param name="id" select="'relatedOrganizations'"/>
      <xsl:with-param name="head">
        <xsl:text>Organizations</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="body">
        <xsl:apply-templates select="$relatedOrganizations" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="count" select="count($relatedOrganizations/*)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@data-xsl='relatedCollections']">
    <xsl:variable name="body">
      <div class="list">
        <ul class="nav nav-tabs">
          <li class="active">
            <a href="#creatorOf" data-toggle="tab">creator of</a>
          </li>
          <li>
            <a href="#referencedIn" data-toggle="tab">referenced in</a>
          </li>
        </ul>
        <div class="tab-content">
          <div class="tab-pane active list" id="creatorOf">
            <xsl:apply-templates select="($archivalRecords-creatorOf)" mode="eac">
              <xsl:sort select="eac:relationEntry"/>
            </xsl:apply-templates>
          </div>
          <div class="tab-pane list" id="referencedIn">
            <xsl:apply-templates select="($archivalRecords-referencedIn)" mode="eac">
              <xsl:sort select="eac:relationEntry"/>
            </xsl:apply-templates>
          </div>
        </div>
      </div>
    </xsl:variable>
    <xsl:call-template name="panel">
      <xsl:with-param name="id" select="'relatedCollections'"/>
      <xsl:with-param name="head">
        <xsl:text>Archival Collections</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="body" select="$body"/>
      <xsl:with-param name="count" select="count($archivalRecords)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='panel'>
    <xsl:param name="id"/>
    <xsl:param name="head"/>
    <xsl:param name="body"/>
    <xsl:param name="count"/>
    <div class="panel panel-default" data-xsl="{$id}">
      <div class="panel-heading">
        <h4>
          <a data-toggle="collapse" data-parent="#relations" href="#{$id}">
            <xsl:copy-of select="$head"/>
            <span class="badge pull-right"><xsl:value-of select="$count"/></span>
          </a>
        </h4>
      </div>
      <div id="{$id}" class="panel-collapse collapse">
        <div class="panel-body">
          <xsl:copy-of select="$body"/>
        </div>
      </div>
    </div>
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
    <xsl:call-template name="sameAs" />
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
    <xsl:apply-templates mode="eac"/>
  </xsl:template>

  <xsl:template match="eac:dateRange" mode="eac">
    <time title="life dates">
    <xsl:apply-templates select="eac:fromDate" mode="eac"/>
    <xsl:text> - </xsl:text>
    <xsl:apply-templates select="eac:toDate" mode="eac"/>
    </time>
  </xsl:template>

  <xsl:template match="*[@data-xsl='life']">
    <xsl:variable name="desc" select="$page/eac:eac-cpf/eac:cpfDescription/eac:description"/>
    <div class="life" data-xsl='life'>
     <dt>Dates:</dt>
     <dd>
       <xsl:apply-templates select="$desc/eac:existDates/eac:dateRange/eac:fromDate" mode="eac"/>
     </dd>
     <dd>
      <xsl:apply-templates select="$desc/eac:existDates/eac:dateRange/eac:toDate" mode="eac"/>
     </dd>
     <dt>Gender:</dt>
     <dd>
       <xsl:apply-templates select="$desc/eac:localDescription[@localType='http://viaf.org/viaf/terms#gender']"/>
     </dd>
    </div>
  </xsl:template>

  <xsl:template match="*[@data-xsl='maybeSame']"><!-- mayBeSame -->
    <xsl:apply-templates select="($maybeSame)[1]" mode="eac"/>
  </xsl:template>

  <xsl:template match="eac:fromDate | eac:toDate | eac:date" mode="eac">
    <xsl:variable name="type" select="lower-case(substring-after(@localType, '#'))"/>
    <xsl:if test="not(starts-with(lower-case(normalize-space(.)),$type))">
      <xsl:value-of select="$type"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="eac:occupations | eac:localDescriptions | eac:functions | eac:mandates | eac:places" mode="eac">
    <xsl:if test="eac:occupation | eac:localDescription | eac:function | eac:mandate | eac:place | eac:placeEntry ">
      <ul>
        <xsl:apply-templates select="eac:occupation | eac:localDescription | eac:function | eac:mandate | eac:place | eac:placeEntry" mode="eac-inlist"/>
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
      <xsl:value-of select="$appBase.path"/>
      <xsl:text>search?sectionType=cpfdescription&amp;f1-occupation=</xsl:text>
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
      <!-- xsl:value-of select="substring-after(@localType, '#')"/ -->
      <!-- xsl:apply-templates select="@localType[.!='subject']"/ -->
      <!-- xsl:text> </xsl:text -->
      <xsl:apply-templates mode="eac"/>
    </xsl:variable>
    <xsl:variable name="normalValue" 
      select="replace(replace(replace(normalize-space(.)
      ,'[^\w\)]+$','')
      ,'--.*$','')
      ,'^VIAF:','')
    "/>
    <xsl:variable name="href">
      <xsl:text>{$appBase.path}search?sectionType=cpfdescription&amp;f1-localDescription=</xsl:text>
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

  <xsl:template match="eac:span[@localType='http://socialarchive.iath.virginia.edu/control/term#Leader06']" mode="eac">
  <!-- 
  06 - Type of record
  a - Language material
  c - Notated music
  d - Manuscript notated music
  e - Cartographic material
  f - Manuscript cartographic material
  g - Projected medium
  i - Nonmusical sound recording
  j - Musical sound recording
  k - Two-dimensional nonprojectable graphic
  m - Computer file
  o - Kit
  p - Mixed materials
  r - Three-dimensional artifact or naturally occurring object
  t - Manuscript language material
  -->
  </xsl:template>
  <xsl:template match="eac:span[@localType='http://socialarchive.iath.virginia.edu/control/term#Leader07']" mode="eac">
  <!--
  07 - Bibliographic level
  a - Monographic component part
  b - Serial component part
  c - Collection
  d - Subunit
  i - Integrating resource
  m - Monograph/Item
  s - Serial
  -->
  </xsl:template>
  <xsl:template match="eac:span[@localType='http://socialarchive.iath.virginia.edu/control/term#Leader08']" mode="eac">
  <!-- 
  08 - Type of control
  # - No specified type
  a - Archival
  -->
  </xsl:template>

  <xsl:template match="eac:list" mode="eac">
    <ul><xsl:apply-templates mode="eac"/></ul>
  </xsl:template>

  <xsl:template match="eac:item" mode="eac">
    <li><xsl:apply-templates mode="eac"/></li>
  </xsl:template>

  <xsl:template match="eac:citation" mode="eac">
    <p class="source"><xsl:apply-templates mode="eac"/></p>
  </xsl:template>

  <xsl:template match="eac:chronItem" mode="eac">
    <div itemscope="itemscope">
      <xsl:apply-templates select="eac:date|eac:dateRange" mode="eac"/>
      <xsl:apply-templates select="eac:placeEntry|eac:event" mode="eac"/>
    </div>
  </xsl:template>

  <xsl:template match="eac:placeEntry[parent::eac:localDescription[@localType='http://viaf.org/viaf/terms#nationalityOfEntity']]" mode="eac eac-inlist">
    <xsl:value-of select="iso:lookup(lower-case(@countryCode))"/>
  </xsl:template>

  <xsl:template match="eac:event[parent::eac:chronItem]|eac:placeEntry[parent::eac:chronItem]" mode="eac">
    <div itemprop="{local-name()}"><xsl:apply-templates mode="eac"/></div>
  </xsl:template>

  <xsl:template match="eac:date[parent::eac:chronItem]|eac:dateRange[parent::eac:chronItem]" mode="eac">
    <time itemprop="{local-name()}"><xsl:apply-templates mode="eac"/></time>
  </xsl:template>

  <xsl:template match="eac:relations" mode="eac">
    <xsl:variable name="people" select="eac:cpfRelation[ends-with(lower-case(@xlink:role),'person') or @cpfRelationType='family'][not(contains(@xlink:arcrole,'#sameAs'))]"/>
    <xsl:if test="$people">
      <h3><span><a href="#">People (<xsl:value-of select="count($people)"/>)</a></span></h3>
      <div>
        <xsl:apply-templates select="$people" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
    <xsl:variable name="corporateBodies" select="
          eac:cpfRelation[
            ends-with(lower-case(@xlink:role),'corporatebody') 
            or @cpfRelationType='associative'
          ][not(ends-with(@xlink:arcrole,'#sameAs'))]">
    </xsl:variable>
    <xsl:if test="$corporateBodies">
      <h3><span><a href="#">Corporate Bodies (<xsl:value-of select="count($corporateBodies)"/>)</a></span></h3>
      <div>
        <xsl:apply-templates select="$corporateBodies" mode="eac">
          <xsl:sort/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
    <xsl:variable name="resources" select="eac:resourceRelation[not(contains(lower-case(@xlink:role),'archival'))]"/>
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

  <xsl:template match="eac:cpfRelation[contains(@xlink:arcrole,'#mayBeSame')]" mode="eac">
    <div data-xsl='maybeSame'><label>Maybe same as</label>
      <a href="{@xlink:href}">
        <xsl:choose>
          <xsl:when test="text()">
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:otherwise>NEED FINAL XML</xsl:otherwise>
        </xsl:choose>
      </a>
    </div>
  </xsl:template>

  <xsl:template match="eac:cpfRelation | eac:resourceRelation" mode="eac">
    <xsl:param name="link-mode" select="'snac'"/>
    <div class="{if (ends-with(lower-case(@xlink:role),'person')) then ('person') 
                 else if (ends-with(lower-case(@xlink:role),'corporatebody')) then ('corporateBody')
                 else if (ends-with(lower-case(@xlink:role),'family')) then ('family')
                 else if (@cpfRelationType) then @cpfRelationType 
                 else 'related'}">
      <xsl:choose>
        <xsl:when test="@xlink:href and text()">
          <a>
            <xsl:apply-templates select="@xlink:href[.!='']"/>
            <xsl:apply-templates select="eac:relationEntry | eac:placeEntry" mode="eac"/>
          </a>
            <xsl:if test="local-name(.)='cpfRelation'">
              <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
            </xsl:if>
          <xsl:variable name="extra-info" select="eac:date | eac:dateRange | eac:dateSet | eac:descriptiveNote | eac:objectXMLWrap/ead:did[1]/ead:repository[1]"/>
          <!-- xsl:if test="$extra-info">
            <div>
              <xsl:apply-templates select="$extra-info" mode="eac">
                <xsl:sort/>
              </xsl:apply-templates>
            </div>
          </xsl:if -->
        </xsl:when>
        <xsl:when test="@xlink:href">
          <a href="{@xlink:href}">
            <xsl:value-of select="substring-after(@xlink:href,'http://')"/>
          </a>
        </xsl:when>
        <xsl:when test="$link-mode = 'worldcat-title'">
          <a href="http://www.worldcat.org/search?q=ti:{
            encode-for-uri(eac:relationEntry)}+au:{
            encode-for-uri(($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part)}"
          >
            <xsl:value-of select="eac:relationEntry"/>
          </a>
              <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/ -->
          <a href="{$appBase.path}search?text={encode-for-uri(eac:relationEntry)};browse=">
            <xsl:value-of select="eac:relationEntry"/>
            <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="eac:objectXMLWrap/mods:mods/mods:name[mods:role/mods:roleTerm='Repository']"/>
    </div>
  </xsl:template>

<!-- 

  <name>
                     <namePart>University of Connecticut</namePart>
                     <role>
                        <roleTerm valueURI="http://id.loc.gov/vocabulary/relators/rps">Repository</roleTerm>
                     </role>
                  </name>
               </mods>

-->

  <xsl:template match="mods:name">
    <xsl:apply-templates select="mods:namePart"/>
  </xsl:template>
  
  <xsl:template match="@xlink:href">
    <xsl:attribute name="href">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
 
  <xsl:template match="@xlink:arcrole" mode="arcrole">
            <span class="arcrole"><xsl:value-of select="substring-after(.,'#')"/></span>
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
  <xsl:template match="*" mode="xxlx">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
 
</xsl:stylesheet>
<!--

Copyright (c) 2014, Regents of the University of California
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
