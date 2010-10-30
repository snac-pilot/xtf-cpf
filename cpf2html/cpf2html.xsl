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
  xmlns:iso="iso:/3166"
  exclude-result-prefixes="#all" 
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

  <!-- in dynaXML-config put
	<spreadsheets formkey="XXXX"/>
	and the "report issue" link will turn on
  -->
  <xsl:variable name="spreadsheets.code" select="document('spreadsheets-code.xml')/spreadsheets/@formkey" />
  <xsl:param name="spreadsheets.formkey" select="$spreadsheets.code"/>

  <xsl:param name="http.URL"/>
  <xsl:variable name="rel.URL" select="replace($http.URL,'http://[^/]*/','/')"/>


  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document('html-template.html')"/>
  <xsl:variable name="footer" select="document('footer.html')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*[local-name()='html']"/>
  </xsl:template>

  <xsl:template match="*:footer">
<div class="clear">&#160;</div>
    <xsl:copy-of select="$footer"/>
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
      <xsl:if test="$spreadsheets.formkey!=''">
        <div><a title="form in new window/tab" target="_blank" href="http://spreadsheets.google.com/viewform?formkey={$spreadsheets.formkey}&amp;entry_0={encode-for-uri($http.URL)}">note data issue</a></div>
      </xsl:if>
      <a title="raw XML" href="/xtf/data/{escape-html-uri($docId)}">view source EAC-CPF</a>
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
    <xsl:variable name="extra-names" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[position()>1]"/>
    <xsl:if test="$extra-names">
      <xsl:element name="{name()}">
        <xsl:attribute name="title" select="'alternative forms of name'"/>
        <xsl:attribute name="class" select="'extra-names'"/>
        <xsl:apply-templates select="$extra-names" mode="extra-names"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eac:authorizedForm" mode="extra-names">
    <xsl:text> </xsl:text>
    <span title="authority" class="authorizedForm"><xsl:apply-templates mode="eac"/></span>
  </xsl:template>

  <xsl:template match="eac:nameEntry" mode="extra-names">
    <xsl:text>
</xsl:text>
    <span>
      <xsl:apply-templates select="eac:part, eac:authorizedForm" mode="extra-names"/>
    </span>
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

  <xsl:template match='*[@tmpl:change-value="dateRange"]'><!-- plus VIAF gender nationality -->
    <xsl:variable name="existDates" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:existDates"/>
    <xsl:if test="$existDates">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="$existDates" mode="eac"/>
      <xsl:text>)</xsl:text>
    <xsl:apply-templates select="
      ($page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[@localType='VIAF:gender']),
      ($page/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[@localType='VIAF:nationality'])" 
      mode="viaf-extra" />
    </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eac:localDescription[@localType='VIAF:nationality']" mode="viaf-extra">
    <span title="nationality" class="nationality"><xsl:apply-templates select="eac:placeEntry" mode="eac"/>&#160;</span>
  </xsl:template>

  <xsl:template match="eac:localDescription[@localType='VIAF:gender']" mode="viaf-extra">
    <span title="gender" class="gender"><xsl:apply-templates mode="eac"/>&#160;</span>
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
      <xsl:text>&#160;</xsl:text>
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

  <xsl:variable name="localDescriptions" select="($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions
        | ($page)/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription"/>

  <xsl:template match='*[@tmpl:condition="localDescriptions"]'>
    <xsl:if test="($localDescriptions)">
      <xsl:call-template name="keep-going">
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

  <xsl:template match='*[@tmpl:condition="relations"]'>
    <xsl:if test="($relations)">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="relations"]'>
    <xsl:variable name="archivalRecords" select="($relations)/eac:resourceRelation[@xlink:role='archivalRecords']" />
    <xsl:variable name="VIAF" select="($page)/eac:eac-cpf/eac:control/eac:sources/eac:source[starts-with(@xlink:href,'VIAF:')]"/>
    <xsl:variable name="viafUrl" select="replace($VIAF/@xlink:href,'^VIAF:(.*)$','viaf.org/viaf/$1/')"/>
    <xsl:if test="$VIAF">
      <div class="related">
        <div class="arcrole">sameAs</div>
        <a title="Virtual International Authority File" href="http://{$viafUrl}"><xsl:value-of select="$viafUrl"/></a>
      </div>
    </xsl:if>
    <xsl:if test="$archivalRecords">
      <h3>Archival Collections</h3>
      <xsl:apply-templates select="($archivalRecords)[contains(@xlink:arcrole,'creatorOf')] , 
                                   ($archivalRecords)[not(contains(@xlink:arcrole,'creatorOf'))]" mode="eac"/>
    </xsl:if>
    <xsl:apply-templates select="$relations" mode="eac"/>
    <xsl:apply-templates select="($relations)/*[eac:cpfRelation]" mode="eac"/>
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
    <xsl:value-of select="eac:fromDate"/>
    <xsl:text> - </xsl:text>
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
      ,'[^\w]+$','')
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
      <xsl:apply-templates select="@localType[.!='subject']"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates mode="eac"/>
    </xsl:variable>
    <xsl:variable name="normalValue" 
      select="replace(replace(replace(normalize-space(.)
      ,'[^\w]+$','')
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

  <xsl:template match="eac:localDescription | eac:occupation | eac:function | eac:mandate | eac:place" mode="eac">
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
    <xsl:if test="eac:cpfRelation[ends-with(lower-case(@xlink:role),'person') or @cpfRelationType='family']"><h3>People</h3></xsl:if>
    <xsl:apply-templates select="eac:cpfRelation[ends-with(lower-case(@xlink:role),'person') or @cpfRelationType='family']" mode="eac"/>
    <xsl:if test="eac:cpfRelation[ends-with(lower-case(@xlink:role),'corporatebody') or @cpfRelationType='associative']"><h3>Corporate Bodies</h3></xsl:if>
    <xsl:apply-templates select="eac:cpfRelation[ends-with(lower-case(@xlink:role),'corporatebody') or @cpfRelationType='associative']" mode="eac"/>
    <xsl:variable name="resources" select="eac:resourceRelation[not(@xlink:role='archivalRecords')]"/>
    <xsl:if test="$resources"><h3>Resources</h3></xsl:if>
    <xsl:apply-templates select="$resources" mode="eac"/>
  </xsl:template>

  <xsl:template match="eac:cpfRelation | eac:resourceRelation" mode="eac">
    <div class="{if (ends-with(lower-case(@xlink:role),'person')) then ('person') 
                 else if (ends-with(lower-case(@xlink:role),'corporatebody')) then ('corporateBody')
                 else if (ends-with(lower-case(@xlink:role),'family')) then ('family')
                 else if (@cpfRelationType) then @cpfRelationType 
                 else 'related'}">
      <xsl:choose>
        <xsl:when test="@xlink:href">
          <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
          <a href="{@xlink:href}"><xsl:apply-templates select="eac:relationEntry | eac:placeEntry" mode="eac"/></a>
          <xsl:variable name="extra-info" select="eac:date | eac:dateRange | eac:dateSet | eac:descriptiveNote | eac:objectXMLWrap/ead:did[1]/ead:repository[1]"/>
          <xsl:if test="$extra-info">
            <div>
              <xsl:apply-templates select="$extra-info" mode="eac"/>
            </div>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@xlink:arcrole" mode="arcrole"/>
          <a href="/xtf/search?text={encode-for-uri(eac:relationEntry)};browse=">
          <xsl:value-of select="eac:relationEntry"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
 
  <xsl:template match="@xlink:arcrole" mode="arcrole">
            <div class="arcrole"><xsl:value-of select="."/></div>
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
