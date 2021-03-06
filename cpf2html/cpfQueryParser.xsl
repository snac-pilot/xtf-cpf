<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:session="java:org.cdlib.xtf.xslt.Session"
  xmlns:freeformQuery="java:org.cdlib.xtf.xslt.FreeformQuery"
  xmlns:math="java:java.lang.Math"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  extension-element-prefixes="session freeformQuery"
  exclude-result-prefixes="#all" 
  version="2.0">
   
  <xsl:import href="../style/crossQuery/queryParser/common/queryParserCommon.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
  <xsl:param name="fieldList" select="'identity text'"/>
  <xsl:param name="text"/>
  <xsl:param name="keyword" select="$text"/>
  <xsl:param name="facet-entityType"/>
  <xsl:param name="browse-json"/>
  <xsl:param name="facet-identityAZ" select="if ($facet-entityType) then 'A' else '0'"/>
  <xsl:param name="recordIds"/>
  <xsl:param name="recordId-merge"/>
  <xsl:param name="recordId-eac-merge"/>
  <xsl:param name="autocomplete"/>
  <xsl:param name="mode"/>
  <xsl:param name="sortGroupsBy" select="'totalDocs'"/>
  <xsl:variable name="stylesheet" 
    select="if ($rmode='dot') then 'cpf2html/dotResults.xsl' 
            else if ($rmode='slickgrid') then 'cpf2html/crossQuery-to-json.xslt'
            else if ($autocomplete) then 'cpf2html/autocomplete.xsl'
            else if (count(parameters/param) = 0 or $rmode='stats' or $rmode='terms') then 'cpf2html/featured-stats.xsl'
            else ('cpf2html/cpfResultFormatter.xsl')"/>

  <xsl:template match="/">
    <xsl:variable name="hasFacets" select="count(parameters/param[matches(@name,'f[0-9]+-')])"/>
    <xsl:choose>
      <xsl:when test="count(parameters/param) = 0">
        <xsl:apply-templates select="." mode="featured"/>
      </xsl:when>
      <xsl:when test="$rmode = 'stats'">
        <xsl:apply-templates select="." mode="stats"/>
      </xsl:when>
      <xsl:when test="$rmode = 'terms'">
        <xsl:apply-templates select="." mode="terms"/>
      </xsl:when>
      <xsl:when test="$mode = 'rnd'">
        <xsl:apply-templates select="." mode="rnd"/>
      </xsl:when>
      <xsl:when test="$recordIds">
        <xsl:apply-templates select="." mode="recordsIds"/>
      </xsl:when>
      <xsl:when test="$autocomplete">
        <xsl:apply-templates select="." mode="autocomplete"/>
      </xsl:when>
      <xsl:when test="$browse-json">
        <xsl:apply-templates select="." mode="browsejson"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="sortDocsBy" select="if ($keyword='') then ('sort-identity') else (false)"/>
        <xsl:variable name="maxDocs" select="if ($rmode='slickgrid' and ($keyword!='' or $hasFacets)) then 25 else 0"/>
        <xsl:variable name="includeEmptyGroups" select="'yes'"/>
<!--
-->
        <query 
          indexPath="index" 
	  returnMetaFields="identity, fromDate, toDate, facet-entityType, facet-recordLevel, facet-Wikipedia, facet-wikithumb, count-LinkedData, count-RelatedRecords, count-BibliographicalResource, count-ArchivalResource, recordIds"
          termLimit="1000" 
          workLimit="4000000" 
          maxSnippets="0"
          style="{$stylesheet}" 
          startDoc="{$startDoc}" 
          maxDocs="{$maxDocs}">
          <xsl:if test="$normalizeScores">
            <xsl:attribute name="normalizeScores" select="$normalizeScores"/>
          </xsl:if>
          <xsl:if test="$explainScores">
            <xsl:attribute name="explainScores" select="$explainScores"/>
          </xsl:if>
          <xsl:if test="$sortDocsBy">
            <xsl:attribute name="sortDocsBy" select="$sortDocsBy"/>
          </xsl:if>
          <xsl:if test="not($rmode='slickgrid')">
            <facet field="facet-entityType" select="*" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-person" select="*[0]" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-family" select="*[0]" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-corporateBody" select="*[0]" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-occupation" select="*[0]" sortGroupsBy="{$sortGroupsBy}"/>
            <!-- facet field="facet-localDescription" select="*[0]" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-ArchivalResource" select="*" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-BibliographicalResource" select="*" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-RelatedRecords" select="*" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-LinkedData" select="*" sortGroupsBy="{$sortGroupsBy}"/ -->
            <facet field="facet-Wikipedia" select="*" sortGroupsBy="{$sortGroupsBy}"/>
            <facet field="facet-recordLevel" select="**" sortGroupsBy="{$sortGroupsBy}"/>
            <spellcheck/>
          </xsl:if>
          <xsl:if test="$text='' and not($hasFacets)"><xsl:value-of select="$keyword!='' or $hasFacets"/>
            <facet field="facet-identityAZ" select="*{
              if ($facet-identityAZ) 
              then concat(
                '|',
                $facet-identityAZ,
                '#',
                $startDoc,
                '-',
                number($startDoc)+number(25)
              )
              else '' }" sortGroupsBy="value" sortDocsBy="sort-identity"/>
          </xsl:if>
          <and>
            <xsl:apply-templates/>
            <xsl:choose>
              <xsl:when test="$facet-entityType">
                <and field="facet-entityType">
                  <term><xsl:value-of select="$facet-entityType"/></term>
                </and>
              </xsl:when>
              <xsl:otherwise>
                <and><allDocs/></and>
              </xsl:otherwise>
            </xsl:choose>
          </and>
        </query>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/" mode="browsejson">
    <xsl:variable name="sortDocsBy" select="(false)"/>
    <xsl:variable name="maxDocs" select="0"/>
    <xsl:variable name="includeEmptyGroups" select="'yes'"/>
    <xsl:variable name="facet-occupation-select">
      <xsl:choose>
        <xsl:when test="$browse-json = 'facet-occupation'">
          <xsl:text>*[</xsl:text>
          <xsl:value-of select="$startDoc"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="number($startDoc)+number(25)"/>
          <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>*[0]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="facet-localDescription-select">
      <xsl:choose>
        <xsl:when test="$browse-json = 'facet-localDescription'">
          <xsl:text>*[</xsl:text>
          <xsl:value-of select="$startDoc"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="number($startDoc)+number(25)"/>
          <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>*[0]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="facet-Location-select">
      <xsl:choose>
        <xsl:when test="$browse-json = 'facet-Location'">
          <xsl:text>*[</xsl:text>
          <xsl:value-of select="$startDoc"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="number($startDoc)+number(25)"/>
          <xsl:text>]</xsl:text>

        </xsl:when>
        <xsl:otherwise>
          <xsl:text>*[0]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <query
      indexPath="index"
      termLimit="1000"
      workLimit="9000000"
      maxSnippets="0"
      style="{$stylesheet}"
      startDoc="{$startDoc}"
      returnMetaFields="facet-identityAZ"
      maxDocs="{$maxDocs}">
          <facet field="facet-Location" select="{$facet-Location-select}" sortGroupsBy="{$sortGroupsBy}"/>
          <facet field="facet-occupation" select="{$facet-occupation-select}" sortGroupsBy="{$sortGroupsBy}"/>
          <facet field="facet-localDescription" select="{$facet-localDescription-select}" sortGroupsBy="{$sortGroupsBy}"/>
          <facet field="facet-Wikipedia" select="*" sortGroupsBy="{$sortGroupsBy}"/>
          <facet field="facet-recordLevel" select="**" sortGroupsBy="{$sortGroupsBy}"/>
          <and>
            <xsl:apply-templates/>
            <xsl:choose>
              <xsl:when test="$facet-entityType">
                <and field="facet-entityType">
                  <term><xsl:value-of select="$facet-entityType"/></term>
                </and>
              </xsl:when>
              <xsl:otherwise>
                <and><allDocs/></and>
              </xsl:otherwise>
            </xsl:choose>
          </and>
      </query>
  </xsl:template>

  <xsl:template match="/" mode="stats">
    <query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
      <facet field="facet-Wikipedia" select="*[0]"/>
      <facet field="facet-wikithumb" select="*[0]"/>
      <facet field="fromDate" select="*[0]"/>
      <facet field="toDate" select="*[0]"/>
      <facet field="facet-entityType" select="**"/>
      <facet field="facet-recordLevel" select="**"/>
      <facet field="facet-Location" select="*[1-10]"/>
      <facet field="facet-occupation" select="*[1-10]"/>
      <facet field="facet-localDescription" select="*[1-10]"/>
      <facet field="facet-resourceRelation" select="*[1-10]"/>
      <facet field="facet-cpfRelation" select="*[1-10]"/>
      <and><allDocs/></and>
    </query>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- autocomplete  http://gist.github.com/612901                            -->
  <!-- ====================================================================== -->

  <!-- autocomplete on identity (the title/subject of an EAC)  -->

  <xsl:template match="/" mode="autocomplete">
    <query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="20" normalizeScores="false"
		returnMetaFields="identity">
      <xsl:choose>
        <xsl:when test="string-length($autocomplete) &gt; 2">
          <and maxSnippets="0">
            <!-- additional search limits -->
            <and field="identity">
              <xsl:apply-templates select="parameters/param[@name='term']/token[@isWord='yes']" mode="autotitle"/>
            </and>
            <xsl:if test="$facet-entityType">
              <and field="facet-entityType">
                <term><xsl:value-of select="$facet-entityType"/></term>
              </and>
            </xsl:if>
          </and>
        </xsl:when>
        <xsl:otherwise> </xsl:otherwise>
      </xsl:choose>
    </query>
  </xsl:template>

  <!-- do a wildcard search on the last word -->
  <xsl:template match="token[position()=last()]" mode="autotitle">
    <xsl:variable name="value">
      <xsl:value-of select="@value"/>
      <xsl:text>*</xsl:text>
    </xsl:variable>
    <or>
      <near slop="13"><term><xsl:value-of select="$value"/></term></near>
      <near slop="13"><term><xsl:value-of select="@value"/></term></near>
    </or>
  </xsl:template>

  <xsl:template match="token" mode="autotitle">
      <term><xsl:value-of select="@value"/></term>
  </xsl:template>

  <!-- random record, based on discussion on xtf-user 
    https://groups.google.com/d/msg/xtf-user/sGbbleerHeM/VD9YbWIC8NwJ -->

  <xsl:template match="/" mode="rnd">
    <xsl:variable 
      name="startDoc"
      select="if ($rmode) then ($rmode) else 1"
    /> 
    <query indexPath="index" termLimit="1000" workLimit="20000000" 
      style="cpf2html/rnd.xsl" maxDocs="1" startDoc="{$startDoc}" >
          <xsl:choose>
            <xsl:when test="$facet-entityType">
              <and field="facet-entityType">
                <term><xsl:value-of select="$facet-entityType"/></term>
              </and>
            </xsl:when>
            <xsl:when test="$recordId-merge='true'">
              <and field="recordId-merge">
                <term>true</term>
              </and>
            </xsl:when>
            <xsl:when test="$recordId-eac-merge='true'">
              <and field="recordId-eac-merge">
                <term>true</term>
              </and>
            </xsl:when>
            <xsl:otherwise>
              <and><allDocs/></and>
            </xsl:otherwise>
          </xsl:choose>
    </query>
  </xsl:template>
  
  <xsl:template match="/" mode="terms">
    <query indexPath="index" style="{$stylesheet}">
      <and></and>
    </query>
  </xsl:template>

  <xsl:template match="/" mode="featured">
    <xsl:variable name="totalFeaturedRecords" select="number(17664)"/>
    <xsl:variable name="rnd" select="xs:integer(round($totalFeaturedRecords * math:random()))" as="xs:integer"/>
    <query indexPath="index" termLimit="1000" workLimit="20000000" 
      returnMetaFields="identity, facet-wikithumb, count-ArchivalResource, facet-Location, recordIds"
      style="{$stylesheet}" maxDocs="25" startDoc="{$rnd}" >
      <and>
        <and field="facet-wikithumb">
          <term>true</term>
        </and>
        <and field="facet-recordLevel">
          <term>hasBiogHist</term>
        </and>
        <not field="count-ArchivalResource">
          <term>1</term>
        </not>
      </and>
    </query>
  </xsl:template>
  
  <xsl:template match="/" mode="recordsIds">
    <query indexPath="index" termLimit="1000" workLimit="20000000" 
      style="{$stylesheet}" maxDocs="1" startDoc="{$startDoc}" >
      <and field="recordIds">
        <term><xsl:value-of select="$recordIds"/></term>
      </and>
    </query>
  </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Parameters Template                                                    -->
   <!-- ====================================================================== -->
   
   <xsl:template match="parameters">
      
      <!-- Find the meta-data and full-text queries, if any -->
      <xsl:variable name="queryParams"
         select="param[not(matches(@name,'style|smode|rmode|expand|brand|sort|startDoc|docsPerPage|sectionType|fieldList|normalizeScores|explainScores|f[0-9]+-.+|facet-.+|browse-*|email|.*-exclude|.*-join|.*-prox|.*-max|.*-ignore|freeformQuery'))]"/>
      <and>
         <!-- Process the meta-data and text queries, if any -->
         <xsl:apply-templates select="$queryParams"/>
         <!-- Process special facet query params -->
         <xsl:if test="//param[matches(@name,'f[0-9]+-.+')]">
            <and maxSnippets="0">
               <xsl:for-each select="//param[matches(@name,'f[0-9]+-.+')]">
                  <and field="{replace(@name,'f[0-9]+-','facet-')}">
                     <term><xsl:value-of select="@value"/></term>
                      <term>
                        <xsl:value-of select="@value"/>
                      </term>
                  </and>
               </xsl:for-each>
            </and>
         </xsl:if>
         
         <!-- Freeform query language -->
         <xsl:if test="//param[matches(@name, '^freeformQuery$')]">
            <xsl:variable name="strQuery" select="//param[matches(@name, '^freeformQuery$')]/@value"/>
            <xsl:variable name="parsed" select="freeformQuery:parse($strQuery)"/>
            <xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
         </xsl:if>
        
         <!-- Unary Not -->
         <xsl:for-each select="param[contains(@name, '-exclude')]">
            <xsl:variable name="field" select="replace(@name, '-exclude', '')"/>
            <xsl:if test="not(//param[@name=$field])">
               <not field="{$field}">
                  <xsl:apply-templates/>
               </not>
            </xsl:if>
         </xsl:for-each>
      
      </and>
      
   </xsl:template>

   <!-- make text= act like keywords -->

   <xsl:template match="param[@name = 'text']">
      <or>
         <and fields="{replace($fieldList, 'text ?', '')}"
              slop="10"
              maxMetaSnippets="0"
              maxContext="60">
            <xsl:apply-templates/>
         </and>
         <and field="text" maxSnippets="3" maxContext="60">
            <xsl:apply-templates/>
            <!-- If there is a sectionType parameter, process it -->
            <xsl:if test="(//param[@name='sectionType']/@value != '')">
               <sectionType>
                  <xsl:apply-templates select="//param[@name='sectionType']/*"/>
               </sectionType>
            </xsl:if>
         </and>
      </or>
   </xsl:template>

   <!-- ====================================================================== -->
   <!-- Facet Query Template                                                   -->
   <!-- ====================================================================== -->
   
   <xsl:template name="facet">
      <xsl:param name="field"/>
      <xsl:param name="topGroups"/>
      <xsl:param name="sort"/>
      
      <xsl:variable name="plainName" select="replace($field,'^facet-','')"/>
      
      <!-- Select facet values based on previously clicked ones. Include the
           ancestors and direct children of these (handles hierarchical facets).
      --> 
      <xsl:variable name="selection">
         <!-- First, select the top groups, or all at the top in expand mode -->
         <xsl:value-of select="if ($expand = $plainName) then '*' else $topGroups"/>
         <!-- For each chosen facet value -->
         <xsl:for-each select="//param[matches(@name, concat('f[0-9]+-',$plainName))]">
            <!-- Select the value itself -->
            <xsl:value-of select="concat('|', @value)"/>
            <!-- And select its immediate children -->
            <xsl:value-of select="concat('|', @value, '::*')"/>
            <!-- And select its siblings, if any -->
            <xsl:value-of select="concat('|', @value, '[siblings]')"/>
            <!-- If only one child, expand it (and its single child, etc.) -->
            <xsl:value-of select="concat('|', @value, '::**[singleton]::*')"/>
         </xsl:for-each>
      </xsl:variable>
      
      <!-- generate the facet query -->
      <!-- in expand mode, don't sort by totalDocs -->
      <facet field="{$field}" 
             select="{$selection}"
             sortGroupsBy="{ if ($expand = $plainName) 
                             then replace($sort, 'totalDocs', 'value') 
                             else $sort }">
      </facet>
   </xsl:template>

   <xsl:template match="param[@name='callback'] | param[@name='mode']">
   </xsl:template>

</xsl:stylesheet>
   <!--
      Copyright (c) 2008, Regents of the University of California
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
