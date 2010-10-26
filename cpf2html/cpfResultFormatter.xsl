<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns="http://www.w3.org/1999/xhtml"
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

   <xsl:output method="xhtml" indent="no" 
      encoding="UTF-8" media-type="text/html; charset=UTF-8" 
      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
      omit-xml-declaration="yes"
      exclude-result-prefixes="#all"/>
   
   
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

   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document('results-template.html')"/>
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
      <xsl:when test="$text='' and ($sectionType='cpfdescription' or $sectionType='' ) and not($page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')]) and not($facet-entityType) ">
        <h1 title="prototype historical resource">
          <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
          <xsl:apply-templates mode="html-template"/>
        </h1>
      </xsl:when>
      <xsl:otherwise>
        <h1>
          <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
          <a href="/xtf/search" title="new search"><xsl:apply-templates mode="html-template"/></a>
        </h1>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:footer" mode="html-template">
    <xsl:copy-of select="$footer"/> 
  </xsl:template>

  <!-- templates that hook the html template to the results -->

  <xsl:template match="*[@tmpl:change-value='html-title']" mode="html-template">
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
  <xsl:text>/xtf/search?autocomplete=yes;</xsl:text>
  <xsl:if test="$facet-entityType">
    <xsl:text>facet-entityType=</xsl:text>
    <xsl:value-of select="$facet-entityType"/>
    <xsl:text>;</xsl:text>
  </xsl:if>
  <xsl:text>callback=?</xsl:text>
</xsl:variable>

<script type="text/javascript">
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

  <xsl:template match="*:a[@tmpl:condition='search']" mode="html-template">
    <xsl:if test="($text!='')">
      <a title="remove keyword search" href="/xtf/search?{editURL:remove(editURL:remove(replace(substring-after($http.URL,'?'),'&amp;',';'),'browse-ignore'),'text')}">
        <xsl:apply-templates select="text()" mode="html-template"/>
      </a>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@tmpl:condition='top-facets']" mode="html-template">
    <div>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <xsl:apply-templates select="$page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')]" mode="top-facets"/>
    </div>
  </xsl:template>
 
  <xsl:template match="param" mode="top-facets">
    <div class="facet-limit" title="search limit">
      <a class="x" href="/xtf/search?{editURL:remove(replace(substring-after($http.URL,'?'),'&amp;',';'), @name)}">☒ </a>
      <xsl:value-of select="@value"/>
      <xsl:text>&#160;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="*[@tmpl:condition='spelling']" mode="html-template">
    <xsl:apply-templates select="$page/crossQueryResult/spelling" mode="spelling"/>
  </xsl:template>

  <xsl:template match="spelling" mode="spelling">
    <xsl:variable name="suggestQ" select="editURL:spellingFix($text,suggestion)"/>
    <div class="spelling-suggestion">Did you mean: 
      <a href="/xtf/search?{editURL:set(substring-after($http.URL,'?'), 'text', $suggestQ)}">
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

  <xsl:template match='*[@tmpl:replace-markup="google-tracking-code"]' mode="html-template">
    <xsl:call-template name="google-tracking-code"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="show-xml"]' mode="html-template">
    <a title="raw XML" href="/xtf/search?{editURL:set(substring-after($http.URL,'?'), 'raw', '1')}">view source CrossQueryResult</a>
  </xsl:template>

  <xsl:template match="*[@tmpl:add-value='search']" mode="html-template">
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

  <xsl:template match='*[@tmpl:process-markup="sectionType"]' mode="html-template">
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
        <script>
  $("span.advancedSearch").hide();
  $("form.cpfSearch").hoverIntent(function () {
    $("span.advancedSearch").css("display", "inline");
  }, function () {
    if ($("span.advancedSearch select").val() === 'cpfdescription') {
      $("span.advancedSearch").fadeOut();
    }
  });
        </script>
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
                     else if ($entity='corporateBody') then 'Corporate Body'
                        else ''"/>
  </xsl:function>

  <xsl:template match='*[@tmpl:replace-markup="navigation"]' mode="html-template">
<ul>
  <xsl:for-each select="('','person','corporateBody','family')">
    <xsl:choose>
      <xsl:when test="$facet-entityType=.">
        <li class="selected"><a><xsl:value-of select="tmpl:entityTypeLabel(.)"/></a></li>
      </xsl:when>
      <xsl:otherwise>
        <li><a href="/xtf/search?{editURL:set($queryStringClean,'facet-entityType',.)}">
          <xsl:value-of select="tmpl:entityTypeLabel(.)"/>
        </a></li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</ul>
  </xsl:template>

  <!-- am I a browse page or a results page ? -->
  <xsl:template match='*[@tmpl:process-markup="resultWrapper"]' mode="html-template">
    <xsl:choose>
      <!-- Browse Identities -->
      <xsl:when test="($page)/crossQueryResult/facet[@field='facet-identityAZ']">
        <div class="g480">
       <xsl:variable name="person-count" select="number(($page)/crossQueryResult/facet[@field='facet-person']/@totalGroups)"/> 
       <xsl:variable name="family-count" select="number(($page)/crossQueryResult/facet[@field='facet-family']/@totalGroups)"/> 
       <xsl:variable name="corporateBody-count" 
            select="number(($page)/crossQueryResult/facet[@field='facet-corporateBody']/@totalGroups)"/>
        <h2><xsl:value-of select="format-number($person-count + $family-count + $corporateBody-count,'#,##0')"/>
            <xsl:text> </xsl:text>
          <xsl:if test="$facet-entityType">
            <xsl:value-of select="tmpl:entityTypeLabel($facet-entityType)"/> 
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:text>Names</xsl:text>
        </h2>

  <h3><xsl:value-of select="tmpl:entityTypeLabel($facet-entityType)"/> Names ⇀  <span title="diacritics disregarded in sorting">Alphabetical Index</span> ⇀  <xsl:value-of select="if ($facet-identityAZ='0') then ('0-9') else $facet-identityAZ"/></h3>


        <div class="AZletters">
        <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-identityAZ']/group" mode="AZletters"/>
        </div>

          <div class="AZlist">
          <!-- process the results -->
          <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-identityAZ']/group[@value=$facet-identityAZ]/docHit" mode="AZlist"/>
          </div>
        </div><!-- end g480 -->
        <div class="g240">
          <h2>Occupations</h2>
          <xsl:call-template name="browse-occupations"/>
        </div>
        <div class="g240">
          <h2>Subjects</h2>
          <xsl:call-template name="browse-subjects"/>
        </div>
      </xsl:when>
      <!-- otherwise continue on with the HTML template -->
      <xsl:otherwise>
        <xsl:element name="{name(.)}">
          <xsl:for-each select="@*[namespace-uri='']">
            <xsl:attribute name="{name(.)}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates mode="html-template"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- browse page -->

  <xsl:template match="group" mode="AZletters">
    <xsl:choose>
     <xsl:when test="not($facet-identityAZ=@value) and @totalDocs &gt; 0">
      <a title="{format-number(@totalDocs,'###,###')}" href="/xtf/search?{editURL:set(editURL:set('','facet-identityAZ', @value),'facet-entityType',$facet-entityType)}">
        <xsl:value-of select="@value"/>
      </a>
     </xsl:when> 
     <xsl:otherwise>
        <span title="{format-number(@totalDocs,'###,###')}"><xsl:value-of select="@value"/></span>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#160;</xsl:text>
  </xsl:template>

  <xsl:template match="docHit" mode="AZlist">
    <xsl:param name="path" select="@path"/>
      <div class="{meta/facet-entityType}">
      <xsl:variable name="href">
          <xsl:text>/xtf/view?docId=</xsl:text>
          <xsl:value-of select="replace(replace(editURL:protectValue($path),'^default:',''),'\s','+')"/>
      </xsl:variable>
      <a>
        <xsl:attribute name="href" select="replace($href,'^http://[^/]*/(.*)','/$1')"/>
        <xsl:value-of select="replace(meta/facet-identityAZ,'^.::','')"/>
      </a>
      </div>
  </xsl:template>

  <!-- results page -->

  <xsl:template match='*[@tmpl:replace-markup="recordLevel"]' mode="html-template">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-recordLevel']" mode="result"/>
  </xsl:template>

  <xsl:template match='*[@tmpl:replace-markup="entityType"]' mode="html-template">
      <xsl:apply-templates select="($page)/crossQueryResult/facet[@field='facet-entityType']" mode="result"/>
  </xsl:template>
  
  <xsl:variable name="occupations" select="($page)/crossQueryResult/facet[@field='facet-occupation']"/>
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

  <xsl:variable name="subjects" select="($page)/crossQueryResult/facet[@field='facet-localDescription']"/>
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
      <xsl:value-of select="format-number(($page)/crossQueryResult/@totalDocs, '###,###')"/>
      <xsl:text> </xsl:text>
      <span title="Encoded Archival Context – Corporate bodies, Persons, and Families">EAC-CPF</span>
      <xsl:text> Records</xsl:text>
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

  <!-- continuation template for conditional sections -->
  <xsl:template name="keep-going">
    <xsl:param name="node"/>
    <xsl:element name="{name($node)}">
      <xsl:for-each select="$node/@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:apply-templates select="($node)/*|($node)/text()"/>
    </xsl:element>
  </xsl:template>


  <!-- templates that format results to HTML --> 

  <xsl:template match="docHit" mode="result">
    <xsl:param name="path" select="@path"/>
    <div class="result">
      <div class="{meta/facet-entityType}">
      <xsl:variable name="href">
          <xsl:text>/xtf/view?docId=</xsl:text>
          <xsl:value-of select="replace(replace(editURL:protectValue($path),'^default:',''),'\s','+')"/>
      </xsl:variable>
      <a>
        <xsl:attribute name="href" select="replace($href,'^http://[^/]*/(.*)','/$1')"/>
        <xsl:apply-templates select="meta/identity[1]"/>
      </a> 
      </div>
      <div><xsl:apply-templates select="meta/entityId"/></div>
      <div><xsl:apply-templates select="snippet" mode="text"/></div>
    </div>
  </xsl:template>

  <xsl:template match="facet" mode="result">
    <ul class="{replace(@field,'facet-','')}">
      <xsl:apply-templates mode="result"/>
      <xsl:if test="@totalGroups &gt; 15">
        <li class="more">
          <xsl:value-of select="@totalGroups"/>
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
    <xsl:variable name="selectLink" select="
         concat('/xtf/', $crossqueryPath, '?',
                editURL:remove(editURL:set($queryStringClean,
                            $nextName, $value),'facet-identityAZ'))">
    </xsl:variable>

    <xsl:variable name="clearLink" select="
         concat('/xtf/', $crossqueryPath, '?',
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
          <a class="x" href="{$clearLink}">☒ </a>
        </xsl:when>
        <xsl:otherwise>
          <a href="{$selectLink}"><xsl:value-of select="@value"/></a>
          <xsl:text> (</xsl:text>
          <xsl:value-of select="@totalDocs"/>
          <xsl:text>)</xsl:text>
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


  <!-- identity transform copies HTML from the layout file -->

  <xsl:template match="*" mode="html-template sectionType-selected">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="html-template"/>
    </xsl:element>
  </xsl:template>

   
</xsl:stylesheet>
   <!--
      Copyright (c) 2010, Regents of the University of California
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
