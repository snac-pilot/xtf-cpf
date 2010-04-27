<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:freeformQuery="java:org.cdlib.xtf.xslt.FreeformQuery"
   extension-element-prefixes="session freeformQuery"
   exclude-result-prefixes="#all" 
   version="2.0">
   
   <xsl:import href="../style/crossQuery/queryParser/common/queryParserCommon.xsl"/>
   <xsl:output method="xml" indent="yes" encoding="utf-8"/>
   <xsl:strip-space elements="*"/>
   <xsl:param name="fieldList" select="'text identity'"/>
   <xsl:param name="keyword"/>
   
  <xsl:template match="/">
    <xsl:variable name="stylesheet" select="'cpf2html/cpfResultFormatter.xsl'"/>
    <xsl:variable name="browse" select="if ($keyword='' and not(/parameters/param[starts-with(@name, 'f[0-9]-')])) then ('yes') else ('no')"/>
    <xsl:variable name="sortDocsBy" select="if ($browse='yes') then ('identity') else (false)"/>
    <xsl:variable name="sortGroupsBy" select="'totalDocs'"/>
    <xsl:variable name="maxDocs" select="if ($browse='yes') then (25) else (25)"/>
    <xsl:variable name="includeEmptyGroups" select="'yes'"/>
      <query 
        indexPath="index" 
        termLimit="1000" 
        workLimit="1000000" 
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
        
         <facet field="facet-recordLevel" select="*[1-5]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-entityType" select="*[1-5]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-person" select="*[1-15]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-corporateBody" select="*[1-15]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-occupation" select="*[1-15]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-localDescription" select="*[1-15]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-cpfRelation" select="*[1-15]" sortGroupsBy="{$sortGroupsBy}"/>
         <facet field="facet-resourceRelation" select="*[1-15]" sortGroupsBy="{$sortGroupsBy}"/>
         <spellcheck/>
         <xsl:apply-templates/>
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
      
         <!-- to enable you to see browse results -->
         <xsl:if test="not(param[starts-with(@name, 'f[0-9]-')] and $keyword='')">
            <allDocs/>
         </xsl:if>

      </and>
      
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
