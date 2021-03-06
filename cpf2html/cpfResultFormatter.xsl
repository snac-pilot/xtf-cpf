<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns=""
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tmpl="xslt://template"
   extension-element-prefixes="session"
   exclude-result-prefixes="#all"
   version="2.0">

   <!-- ====================================================================== -->
   <!-- Import Common Templates                                                -->
   <!-- ====================================================================== -->
   
   <xsl:import href="google-tracking.xsl"/>
   <xsl:include href="../style/crossQuery/resultFormatter/common/resultFormatterCommon.xsl"/>
   <!-- xsl:include href="../style/crossQuery/resultFormatter/default/searchForms.xsl"/ -->
   
   <!-- ====================================================================== -->
   <!-- Output                                                                 -->
   <!-- ====================================================================== -->

   <xsl:output encoding="UTF-8" media-type="text/html" indent="yes"
      method="xhtml" doctype-system="about:legacy-compat"
      omit-xml-declaration="yes"
      exclude-result-prefixes="#all"/>

   <xsl:param name="asset-base.value"/>
   <xsl:param name="appBase.path"/>
   <xsl:include href="data-xsl-asset.xsl"/> 
   
   <!-- ====================================================================== -->
   <!-- Local Parameters                                                       -->
   <!-- ====================================================================== -->
 
   <xsl:param name="css.path" select="concat($xtfURL, 'css/default/')"/>
   <xsl:param name="icon.path" select="concat($xtfURL, 'icons/default/')"/>
   <xsl:param name="docHits" select="/crossQueryResult/docHit"/>
   <xsl:param name="http.URL"/>
   <!-- xsl:param name="text"/ -->
   <!-- xsl:param name="keyword" select="$text"/ -->
   <xsl:param name="facet-entityType"/>
   <xsl:param name="facet-identityAZ" select="if ($facet-entityType) then 'A' else '0'"/>
   <xsl:param name="recordId-merge"/>
   <xsl:param name="recordId-eac-merge"/>
   <xsl:param name="browse-json"/>

   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document('search.html')"/>
  <xsl:variable name="footer" select="document('footer.html')"/>
  <xsl:variable name="queryStringClean" select="replace($queryString,'http://.*/xtf/search','')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*[local-name()='html']" mode="html-template"/>
    <xsl:comment>
        url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="*:h1" mode="html-template">
    <xsl:choose>
      <xsl:when test="$text='' and ($sectionType='cpfdescription' or $sectionType='' ) and not($page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')]) and not($facet-entityType) and not($facet-identityAZ)">
        <h1 title="prototype historical resource">
          <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
          <xsl:apply-templates mode="html-template"/>
        </h1>
      </xsl:when>
      <xsl:otherwise>
        <h1>
          <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
          <a href="{$appBase.path}search" title="new search"><xsl:apply-templates mode="html-template"/></a>
        </h1>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:footer" mode="html-template">
    <xsl:copy-of select="$footer"/> 
  </xsl:template>

  <!-- templates that hook the html template to the results -->

  <xsl:template match="*[@tmpl:change-value='html-title']|*[@data-xsl='html-title']" mode="html-template">
    <title>
      <xsl:text>Find Records: </xsl:text>
      <xsl:value-of select="tmpl:entityTypeLabel($facet-entityType), $page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')]/@value, $text"/>
    </title>
  </xsl:template>

  <xsl:template match="*[@tmpl:condition='autocomplete']" mode="html-template">
    <xsl:choose>
      <xsl:when test="$page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')]"/>
      <xsl:otherwise>
<xsl:variable name="autoUrl">
  <xsl:value-of select="$appBase.path"/>
  <xsl:text>search?autocomplete=yes;</xsl:text>
  <xsl:if test="$facet-entityType">
    <xsl:text>facet-entityType=</xsl:text>
    <xsl:value-of select="$facet-entityType"/>
    <xsl:text>;</xsl:text>
  </xsl:if>
  <xsl:text>callback=?</xsl:text>
</xsl:variable>

<script>
/*jslint indent: 2 */
/*global $ */
  $(function () {
    $("input#userInput").autocomplete({
      source: "<xsl:value-of select="$autoUrl"/>",  /* JSONP '?' turns to callback; term=letters gets added */
      minLength: 3,
      delay: 250
    }).keydown(function (e) {            /* http://stackoverflow.com/questions/3785993/ */
      if (e.keyCode === 13) {
        $(this).autocomplete("close");
        $(this).closest('form').trigger('submit');
      }
    });
  });
</script>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:a[@tmpl:condition='search']|*[@data-xsl='clear-search']" mode="html-template">
    <xsl:if test="($text!='')">
      <a title="remove keyword search" class="ppull-left" href="{$appBase.path}search?{editURL:remove(editURL:remove(replace(substring-after($http.URL,'?'),'&amp;',';'),'browse-ignore'),'text')}">
        <xsl:apply-templates select="text()" mode="html-template"/>
      </a>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@tmpl:condition='top-facets']|*[@data-xsl='top-facets']" mode="html-template">
    <div>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <xsl:apply-templates select="$page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')]" mode="top-facets"/>
    </div>
  </xsl:template>

  <xsl:template match="param[@name='f00-recordLevel']|param[@name='f00-Wikipedia']" mode="top-facets"/>
 
  <xsl:template match="param" mode="top-facets">
    <div class="facet-limit" title="search limit">
      <a title="remove {@value}" class="x" href="{$appBase.path}search?{editURL:remove(replace(substring-after($http.URL,'?'),'&amp;',';'), @name)}">☒</a>
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="@value"/>
      <xsl:text>&#160;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="*[@tmpl:condition='spelling']|*[@data-xsl='spelling']" mode="html-template">
    <xsl:apply-templates select="$page/crossQueryResult/spelling" mode="spelling"/>
  </xsl:template>

  <xsl:template match="spelling" mode="spelling">
    <xsl:variable name="suggestQ" select="editURL:spellingFix($text,suggestion)"/>
    <div class="spelling-suggestion">Did you mean: 
      <a href="{$appBase.path}search?{editURL:set(substring-after($http.URL,'?'), 'text', $suggestQ)}">
        <xsl:value-of select="$suggestQ"/>
      </a>
    </div>
  </xsl:template>

  <xsl:function name="editURL:spellingFix">
    <xsl:param name="query"/>
    <xsl:param name="suggestion"/>
    <xsl:variable name="thisTerm" select="($suggestion)[1]"/>
    <xsl:variable name="nextTerm" select="($suggestion)[position()&gt;1]"/>
    <xsl:variable name="changedQuery" select="replace($query, $thisTerm/@originalTerm, $thisTerm/@suggestedTerm)"/>
    <xsl:choose>
      <xsl:when test="boolean($nextTerm)">
        <xsl:value-of select="editURL:spellingFix($changedQuery,$nextTerm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$changedQuery"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match='*[@tmpl:replace-markup="google-tracking-code"]|*[@data-xsl-ga="ga"]' mode="html-template">
    <xsl:call-template name="google-tracking-code"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="show-xml"]' mode="html-template">
    <a title="raw XML" href="{$appBase.path}search?{editURL:set(substring-after($http.URL,'?'), 'raw', '1')}">view source CrossQueryResult</a>
  </xsl:template>

  <xsl:template match="*[@tmpl:add-value='search']|*[@data-xsl='search']" mode="html-template">
    <!-- hidden search elements -->
    <xsl:apply-templates select="$page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')],$page/crossQueryResult/parameters/param[@name='facet-entityType']" mode="hidden-facets"/>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:attribute name="value">
        <xsl:value-of select="$text"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="param" mode="hidden-facets">
    <input type="hidden" value="{@value}" name="{@name}"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:process-markup="sectionType"]|*[@data-xsl="sectionType"]' mode="html-template">
    <xsl:element name="{name(.)}">
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <xsl:attribute name="title"><xsl:value-of select="@title"/></xsl:attribute>
      <xsl:for-each select="@name">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="sectionType-selected"/>
      <xsl:if test="
        $sectionType='cpfdescription' 
        or editURL:remove(editURL:remove($queryStringClean,'facet-identityAZ'),'facet-entityType')=''
      ">
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:select" mode="sectionType-selected">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="sectionType-selected"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:option" mode="sectionType-selected">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <!-- add selected attribute / default cpfdescription if no serach -->
      <xsl:if test="($sectionType = @value) 
		or ( $text='' and @value = 'cpfdescription')">
        <xsl:attribute name="selected" select="'selected'"/>
      </xsl:if>
      <xsl:apply-templates mode="html-template"/>
    </xsl:element>
  </xsl:template>

  <xsl:function name="tmpl:entityTypeLabel">
    <xsl:param name="entity"/>
    <xsl:value-of select="if ($entity='') then 'All' 
                     else if ($entity='person') then 'Person'
                     else if ($entity='family') then 'Family'
                     else if ($entity='corporateBody') then 'Organization'
                        else ''"/>
  </xsl:function>

  <xsl:function name="tmpl:entityTypeIcon">
    <xsl:param name="entity"/>
    <xsl:variable name="type" select="if ($entity='') then '' 
                     else if ($entity='person') then 'ind'
                     else if ($entity='family') then 'fam'
                     else if ($entity='corporateBody') then 'org'
                        else ''"/>
    <xsl:if test="$type">
      <span class="icon-{$type} x2"></span>
    </xsl:if>
  </xsl:function>

  <xsl:template match='*[@tmpl:replace-markup="navigation"]|*[@data-xsl="navigation"]' mode="html-template">
<ul>
  <xsl:for-each select="('','person','family','corporateBody')">
    <xsl:choose>
      <xsl:when test="$facet-entityType=.">
        <li class="selected active">
          <a>
            <xsl:copy-of select="tmpl:entityTypeIcon(.)"/>
            <xsl:value-of select="tmpl:entityTypeLabel(.)"/>
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li><a href="{$appBase.path}search?{editURL:set($queryStringClean,'facet-entityType',.)}">
          <xsl:copy-of select="tmpl:entityTypeIcon(.)"/>
          <xsl:value-of select="tmpl:entityTypeLabel(.)"/>
        </a></li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</ul>
  </xsl:template>

  <xsl:template match="docHit" mode="AZlist">
    <xsl:param name="path" select="@path"/>
      <div class="{meta/facet-entityType}{if (meta/facet-recordLevel[text()='hasBiogHist']) then (' hasBiogHist') else ('')}">
      <xsl:variable name="href">
          <xsl:value-of select="$appBase.path"/>
          <xsl:text>view?docId=</xsl:text>
          <xsl:value-of select="replace(replace(editURL:protectValue($path),'^default:',''),'\s','+')"/>
      </xsl:variable>
      <a>
        <xsl:attribute name="href" select="replace($href,'^http://[^/]*/(.*)','/$1')"/>
        <xsl:value-of select="replace(meta/facet-identityAZ,'^.::','')"/>
      </a>
      </div><xsl:text>
</xsl:text>
  </xsl:template>

  <!-- results page -->

  <xsl:template match='*[@tmpl:replace-markup="recordLevel"]' mode="html-template">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-recordLevel']" mode="result"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="entityType"]' mode="html-template">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-entityType']" mode="result"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="version"]' mode="html-template">
    <xsl:copy-of select="document('VERSION')"/>
  </xsl:template>
  
  <xsl:variable name="occupations" select="($page)/crossQueryResult/facet[@field='facet-occupation']"/>
  <xsl:variable name="subjects" select="($page)/crossQueryResult/facet[@field='facet-localDescription']"/>

  <xsl:template match="*[@tmpl:condition='occupations']" mode="html-template">
    <xsl:if test="($occupations)/*">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="occupations"]' mode="html-template" name="browse-occupations">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-occupation']" mode="result"/>
  </xsl:template>

  <xsl:template match="*[@tmpl:condition='subjects']" mode="html-template">
    <xsl:if test="($subjects)/*">
      <xsl:call-template name="keep-going">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match='*[@tmpl:replace-markup="subjects"]' mode="html-template" name="browse-subjects">
      <xsl:apply-templates select="$subjects" mode="result"/>
  </xsl:template>



  <xsl:template match='*[@tmpl:replace-markup="cpfRelation"]' mode="html-template">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-cpfRelation']" mode="div-result"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="resourceRelation"]' mode="html-template">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-resourceRelation']" mode="div-result"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="totalDocs"]' mode="html-template">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match='*[@tmpl:change-value="results"]' mode="html-template">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:apply-templates select="$docHits" mode="result"/>
      <xsl:if test="number(($page)/crossQueryResult/@totalDocs) &gt; 2500">
      <div class="result more">
        <xsl:value-of select="format-number(number(($page)/crossQueryResult/@totalDocs) - 2500,'###,###')"/> not shown
      </div>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[@data-xsl='footer']" mode="html-template">
    <xsl:copy-of select="document('footer2.html')"/>
  </xsl:template>

  <xsl:template match="*[@tmpl:replace-markup='AZ']|*[@data-xsl='AZ']" mode="html-template">
        <ul class="alphascroll">
          <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-identityAZ']/group" mode="AZletters"/>
        </ul>
  <!-- div class="pull-right">
  <button id="prev" type="button" class="btn btn-sm btn-default">
    <span class="glyphicon glyphicon-backward"></span>
  </button>
  <button id="next" type="button" class="btn btn-sm btn-default">
    <span class="glyphicon glyphicon-forward"></span>
  </button>
  </div -->
  </xsl:template>

  <xsl:template match="group" mode="AZletters">
    <xsl:choose>
     <xsl:when test="not($facet-identityAZ=@value) and @totalDocs &gt; 0">
      <li><a title="{format-number(@totalDocs,'###,###')}" href="{$appBase.path}search?{
                    editURL:set(editURL:set(editURL:set(editURL:set('','facet-identityAZ', @value),
                                                    'facet-entityType',$facet-entityType),
                                                      'recordId-merge',$recordId-merge),
                                              'recordId-eac-merge',$recordId-eac-merge) }"
            data-toggle="tooltip" data-placement="right"
          >
         <xsl:value-of select="@value"/>
       </a></li>
     </xsl:when>
     <xsl:otherwise>
        <li data-toggle="tooltip" data-placement="right"  title="{format-number(@totalDocs,'###,###')}"><xsl:value-of select="@value"/></li>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="*[@data-xsl='browsenav']" mode="html-template">
               <div class="browsenav" data-xsl='browsenav'>
                  <ul>
                     <xsl:if test="$text=''">
                       <li><a href="search">Featured</a></li>
                     </xsl:if>
                     <li class="{if ($browse-json!='') then '' else 'active'}">
                        <a href="search?{ editURL:remove($queryString, 'browse-json')}">Name</a>
                     </li>
                     <li class="{if ($browse-json!='facet-occupation') then '' else 'active'}">
                        <a href="search?{ editURL:set(
                             editURL:remove($queryString, 'facet-occupation'),
                             'browse-json', 'facet-occupation') }">Occupation</a>
                     </li>
                     <li class="{if ($browse-json!='facet-localDescription') then '' else 'active'}">
                        <a href="search?{ editURL:set(
                             editURL:remove($queryString, 'facet-localDescription'),
                             'browse-json', 'facet-localDescription') }">Subject</a>
                     </li>
                     <li class="{if ($browse-json!='facet-Location') then '' else 'active'}">
                        <a href="search?{ editURL:set(
                             editURL:remove($queryString, 'facet-Location'),
                             'browse-json', 'facet-Location') }">Location</a>
                     </li>
                  </ul>
               </div>
  </xsl:template>

  <xsl:template match='*[@data-xsl="BW-facet"]' mode="html-template">
                   <div data-xsl='BW-facet' class="filternav">
                                     <small>Show records with: </small>
                  <ul>
                     <li>
                        <a href="{$appBase.path}search?{
                              editURL:remove(editURL:remove($queryString, 'f00-Wikipedia'),'f00-recordLevel')
                                                       }" 
                           class="{if ($page//param[@name='f00-Wikipedia']|$page//param[@name='f00-recordLevel']) then '' else 'active'}"
                           role="button">All</a>
                     </li>
                     <li>
                        <a href="{$appBase.path}search?{
                                              editURL:remove(
                                                editURL:set($queryString, 'f00-recordLevel', 'hasBiogHist'),
                                                'f00-Wikipedia')
                                                       }" 
                           class="{if ($page//param[@name='f00-recordLevel']) then 'active' else ''
                                 }{if ($page/crossQueryResult/facet[@field='facet-recordLevel']/group[@value='hasBiogHist'])
                                   then '' else 'disabled'
                                 }"
                           role="button"
                        >
                           <div class="icon-B"></div>Biographies
                        </a>
                     </li>
                     <li>
                        <a href="{$appBase.path}search?{
                                              editURL:remove(
                                                editURL:set($queryString, 'f00-Wikipedia', 'Wikipedia'),
                                                'f00-recordLevel')
                                                       }" 
                           class="{if ($page//param[@name='f00-Wikipedia']) then 'active' else ''
                                  }
                                  {if ($page/crossQueryResult/facet[@field='facet-Wikipedia']/@totalDocs = 0)
                                   then 'disabled' else ''
                                  }"
                           role="button">
                           <div class="icon-W"></div>Wikipedia Links
                        </a>
                     </li>
                  </ul>
                  </div>
  </xsl:template>


  <xsl:template match="*[@data-xsl='result_summary']" mode="html-template">
    <div class="result_summary" data-xsl="result_summary"><i>
      <xsl:if test="not($browse-json)">Showing </xsl:if>
      <xsl:if test="$browse-json = 'facet-occupation'">Occupations from </xsl:if>
      <xsl:if test="$browse-json = 'facet-localDescription'">Subjects from </xsl:if>
      <xsl:if test="$browse-json = 'facet-Locations'">Locations from </xsl:if>
      <xsl:value-of select="format-number($page/crossQueryResult/@totalDocs, '###,###')"/>
      <xsl:text> result</xsl:text>
      <xsl:if test="$page/crossQueryResult/@totalDocs != 1"><xsl:text>s</xsl:text></xsl:if>
      <xsl:if test="$text"> for
      "<xsl:value-of select="$text"/>"
      </xsl:if>
      <span><xsl:apply-templates select="$page/crossQueryResult/parameters/param[@name='facet-entityType'],
                                         $page/crossQueryResult/parameters/param[ends-with(@name,'occupation')], 
                                         $page/crossQueryResult/parameters/param[ends-with(@name,'localDescription')], 
                                         $page/crossQueryResult/parameters/param[ends-with(@name,'Location')], 
                                         $page/crossQueryResult/parameters/param[starts-with(@name,'f00')]" 
               mode="result_summary"/></span>
      </i>
    </div>
  </xsl:template>

  <xsl:template match="param[@name='f00-recordLevel']" mode="result_summary">
    with Biography/History
  </xsl:template>

  <xsl:template match="param[@name='f00-Wikipedia']" mode="result_summary">
    with Wikipedia link
  </xsl:template>

  <xsl:template match="param[@name='facet-entityType']" mode="result_summary">
    in <xsl:value-of select="replace(@value,'corporateBody','Organization')"/>
  </xsl:template>

  <xsl:template match="param[ends-with(@name,'localDescription')]" mode="result_summary">
    Subject: «<xsl:value-of select="@value"/>»
  </xsl:template>

  <xsl:template match="param[ends-with(@name,'occupation')]" mode="result_summary">
    Occupation: «<xsl:value-of select="@value"/>»
  </xsl:template>

  <xsl:template match="param[ends-with(@name,'Location')]" mode="result_summary">
    Location: «<xsl:value-of select="@value"/>»
  </xsl:template>

  <xsl:template match="*[@tmpl:replace-markup='sumnav']" mode="html-template">

<ul tmpl:replace-markup="sumnav" class="btn-group" style="padding-left: 0; margin-bottom: 0;">
      <li type="button" class="btn btn-sm btn-default {if ($browse-json) then '' else 'active'}">
        <a href="search?{ editURL:remove($queryString, 'browse-json')}">
          <xsl:value-of select="format-number(($page)/crossQueryResult/@totalDocs, '###,###')"/>
          <xsl:choose>
            <xsl:when test="($page)/crossQueryResult/@totalDocs &gt; 1">
              <xsl:text> identities </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> identity </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </li>
   <li type="button" class="btn btn-sm btn-default {if ($browse-json='facet-occupation') then 'active' else''}"><a href="search?{ editURL:set(
                             editURL:remove($queryString, 'facet-occupation'),
                             'browse-json', 'facet-occupation')
}"><xsl:value-of select="format-number(($page)/crossQueryResult/facet[@field='facet-occupation']/@totalGroups, '###,###')"/> occupations</a></li>
   <li type="button" class="btn btn-sm btn-default {if ($browse-json='facet-localDescription') then 'active' else''}"><a href="search?{ editURL:set(
                             editURL:remove($queryString, 'facet-localDescription'),
                             'browse-json', 'facet-localDescription')
}"><xsl:value-of select="format-number(($page)/crossQueryResult/facet[@field='facet-localDescription']/@totalGroups, '###,###')"/> subjects</a></li>
</ul>
  </xsl:template>

  <!-- continuation template for conditional sections -->
  <xsl:template name="keep-going">
    <xsl:param name="node"/>
    <xsl:element name="{name($node)}">
      <xsl:for-each select="$node/@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:apply-templates select="($node)/*|($node)/text()" mode="html-template"/>
    </xsl:element>
  </xsl:template>


  <!-- templates that format results to HTML --> 

  <xsl:template match="docHit" mode="result">
    <xsl:param name="path" select="@path"/>
    <div class="result">
      <div class="{meta/facet-entityType}">
      <a>
        <xsl:attribute name="href" select="replace(meta/recordIds[1],'^http://n2t.net','')"/>
        <xsl:apply-templates select="meta/identity[1]"/>
      </a> 
      </div>
      <div><xsl:apply-templates select="meta/entityId"/></div>
      <div><xsl:apply-templates select="snippet" mode="text"/></div>
    </div>
  </xsl:template>

  <xsl:template match="facet[@totalDocs='0']" mode="result"/>

  <xsl:template match="facet" mode="result">
    <ul class="{replace(@field,'facet-','')}">
      <xsl:apply-templates mode="result"/>
      <xsl:if test="@totalGroups &gt; 15">
        <li class="more">
          <xsl:value-of select="format-number(@totalGroups,'###,###')"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="replace(@field,'facet-','')"/>
          <xsl:text>s</xsl:text>
          <xsl:text> not shown</xsl:text>
        </li>
      </xsl:if>
    </ul>
  </xsl:template>

<!-- 
  <xsl:template match="group[not(parent::group) and @totalSubGroups = 0]" exclude-result-prefixes="#all">
  </xsl:template>
-->

  <xsl:template match="group" mode="result">
    <li> 
      <xsl:call-template name="group-value">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </li>
  </xsl:template>


  <xsl:template name="group-value">
    <xsl:param name="node"/>
    <xsl:variable name="field" select="replace(ancestor::facet/@field, 'facet-(.*)', '$1')"/>
    <xsl:variable name="value" select="@value"/>
    <xsl:variable name="nextName" select="editURL:nextFacetParam($queryString, $field)"/>
    <xsl:variable name="queryStringCleanHomePage" select="
      if ($sectionType)
      then $queryStringClean
      else editURL:set($queryStringClean,'sectionType', 'cpfdescription')
    "/>
    <xsl:variable name="selectLink" select="
         concat($appBase.path, $crossqueryPath, '?',
                editURL:remove(editURL:set($queryStringCleanHomePage,
                            $nextName, $value),'facet-identityAZ'))">
    </xsl:variable>

    <xsl:variable name="clearLink" select="
         concat($appBase.path, $crossqueryPath, '?',
                editURL:replaceEmpty(editURL:remove($queryString, concat('f[0-9]+-',$field,'=',$value)),
                                     'browse-all=yes'))">
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="//param[matches(@name,concat('f[0-9]+-',$field))]/@value=$value">
          <xsl:attribute name="class">selected</xsl:attribute>
          <xsl:apply-templates select="$node" mode="beforeGroupValue"/>
            <xsl:value-of select="($node)/$value"/>
          <xsl:apply-templates select="$node" mode="afterGroupValue"/>
          <xsl:text> </xsl:text>
          <a class="x" title="remove {($node)/$value}" href="{$clearLink}">☒ </a>
        </xsl:when>
        <xsl:otherwise>
          <a href="{$selectLink}"><xsl:value-of select="@value"/></a>
          <span style="padding-left: 0.25em; font-size:80%;"><xsl:value-of select="format-number(@totalDocs,'###,###')"/></span>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="facet" mode="div-result">
    <div class="{replace(@field,'facet-','')}">
      <xsl:apply-templates mode="div-result"/>
      <xsl:if test="@totalGroups &gt; 15">
        <div class="more">
          <xsl:text>see all </xsl:text>
          <xsl:value-of select="@totalGroups"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="replace(@field,'facet-','')"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="group" mode="div-result">
    <div> 
      <xsl:call-template name="group-value">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </div>
  </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Bookbag Templates                                                      -->
   <!-- ====================================================================== -->
   
   
   <!-- ====================================================================== -->
   <!-- Browse Template                                                        -->
   <!-- ====================================================================== -->
   
   
   <!-- ====================================================================== -->
   <!-- Document Hit Template                                                  -->
   <!-- ====================================================================== -->
   
   
   <!-- ====================================================================== -->
   <!-- Snippet Template (for snippets in the full text)                       -->
   <!-- ====================================================================== -->
   
   <xsl:template match="snippet" mode="text" exclude-result-prefixes="#all">
      <xsl:text>...</xsl:text>
      <xsl:apply-templates mode="text"/>
      <xsl:text>...</xsl:text>
      <br/>
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Term Template (for snippets in the full text)                          -->
   <!-- ====================================================================== -->
   
   <xsl:template match="term" mode="text" exclude-result-prefixes="#all">
      <xsl:variable name="path" select="ancestor::docHit/@path"/>
      <xsl:variable name="display" select="ancestor::docHit/meta/display"/>
      <xsl:variable name="hit.rank"><xsl:value-of select="ancestor::snippet/@rank"/></xsl:variable>
      <xsl:variable name="snippet.link">    
         <xsl:call-template name="dynaxml.url">
            <xsl:with-param name="path" select="$path"/>
         </xsl:call-template>
         <xsl:value-of select="concat(';hit.rank=', $hit.rank)"/>
      </xsl:variable>
      
      <xsl:choose>
         <xsl:when test="ancestor::query"/>
         <xsl:when test="not(ancestor::snippet) or not(matches($display, 'dynaxml'))">
            <span class="hit"><xsl:apply-templates/></span>
         </xsl:when>
         <xsl:otherwise>
            <a href="{$snippet.link}" class="hit"><xsl:apply-templates/></a>
         </xsl:otherwise>
      </xsl:choose> 
      
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Term Template (for snippets in meta-data fields)                       -->
   <!-- ====================================================================== -->
   
   <xsl:template match="term" exclude-result-prefixes="#all">
      <xsl:choose>
         <xsl:when test="ancestor::query"/>
         <xsl:otherwise>
            <span class="hit"><xsl:apply-templates/></span>
         </xsl:otherwise>
      </xsl:choose> 
      
   </xsl:template>



  <xsl:template match="form[@action='/xtf/search']" mode="html-template">
    <form method="GET" action="{$appBase.path}search">
      <xsl:apply-templates mode="html-template"/>
    </form>
  </xsl:template>


  <!-- identity transform copies HTML from the layout file -->

  <xsl:template match="@*|node()" mode="html-template">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="html-template"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="sectionType-selected">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="sectionType-selected"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
   <!--
      Copyright (c) 2014, Regents of the University of California
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without 
      modification, are permitted provided that the following conditions are 
      met:
      
      - Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
      - Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
      - Neither the name of the University of California nor the names of its
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.
      
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
