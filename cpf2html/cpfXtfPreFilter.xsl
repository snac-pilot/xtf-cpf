<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:ead="urn:isbn:1-931666-22-9"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:xs="http://www.w4.org/2001/XMLSchema" 
  xmlns:iso="iso:/3166"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
  xmlns:CharUtils="java:org.cdlib.xtf.xslt.CharUtils"
  xmlns:dbpedia-owl="http://dbpedia.org/ontology/"
  exclude-result-prefixes="#all" 
  version="2.0">

  <!-- preFilter for eac-cpf in XTF -->

  <xsl:include href="iso_3166.xsl"/>
  <xsl:include href="iso_639-2.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:param name="hasDescription">
    <xsl:choose>
      <xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:description">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <!-- Root Template --> 
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="get-meta"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- add metadata to XTF index -->
  <xsl:template name="get-meta">
    <xsl:variable name="mergeCount"><xsl:value-of select="count(/eac:eac-cpf/eac:control/eac:otherRecordId[ends-with(@localType,'MergedRecord')])"/></xsl:variable>
    <meta xmlns="">
      <xsl:apply-templates select="/eac:eac-cpf" mode="main-facet"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:control" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:identity" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityId" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate" mode="meta"/>

      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupation" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription" mode="meta"/>
      <!-- is the following legal EAC? -->
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescription[not(starts-with(@localType,'VIAF'))]" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:cpfRelation" mode="meta"/>
      <xsl:apply-templates select="/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:resourceRelation" mode="meta"/>
      <mergeCount xtf:meta="yes"><xsl:value-of select="$mergeCount"/></mergeCount>
    </meta>
  </xsl:template>

  <xsl:template match="eac:eac-cpf" mode="main-facet">
    <facet-recordLevel xtf:facet="yes" xtf:meta="yes">
      <xsl:choose>
        <xsl:when test="eac:cpfDescription/eac:description/eac:biogHist">
          <xsl:text>hasBiogHist</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>sparse</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </facet-recordLevel>
    <facet-entityType xtf:facet="yes" xtf:meta="yes">
      <xsl:value-of select="eac:cpfDescription/eac:identity/eac:entityType"/>
    </facet-entityType>
    <xsl:apply-templates select="eac:cpfDescription/eac:relations/eac:cpfRelation[ends-with(@xlink:arcrole,'sameAs')][starts-with(@xlink:href,'http://en.wikipedia.org/wiki/')]" mode="main-facets"/>
    <xsl:for-each-group 
      select="eac:cpfDescription/eac:relations/eac:resourceRelation//mods:name[mods:role/mods:roleTerm='Repository']/mods:namePart | eac:cpfDescription/eac:relations/eac:resourceRelation//ead:repository/ead:corpname"
      group-by="."
    >
      <xsl:sort order="ascending" select="."/>
      <xsl:apply-templates select="." mode="main-facets"/>
    </xsl:for-each-group>

  <xsl:variable name="ArchivalResource"
    select="eac:cpfDescription/eac:relations/eac:resourceRelation[ends-with(@xlink:role,'#ArchivalResource')]"/>
  <xsl:variable name="BibliographicalResource"
    select="eac:cpfDescription/eac:relations/eac:resourceRelation[ends-with(@xlink:role,'#BibliographicResource')]"/>
  <xsl:variable name="RelatedRecords"
    select="eac:cpfDescription/eac:relations/eac:cpfRelation[not(ends-with(@xlink:arcrole,'#sameAs'))]"/>
  <xsl:variable name="LinkedData"
    select="eac:cpfDescription/eac:relations/eac:cpfRelation[ends-with(@xlink:arcrole,'#sameAs')]"/>

  <xsl:call-template name="count-facet">
    <xsl:with-param name="facet" select="'ArchivalResource'"/>
    <xsl:with-param name="tree" select="$ArchivalResource"/>
  </xsl:call-template>
  <xsl:call-template name="count-facet">
    <xsl:with-param name="facet" select="'BibliographicalResource'"/>
    <xsl:with-param name="tree" select="$BibliographicalResource"/>
  </xsl:call-template>
  <xsl:call-template name="count-facet">
    <xsl:with-param name="facet" select="'RelatedRecords'"/>
    <xsl:with-param name="tree" select="$RelatedRecords"/>
  </xsl:call-template>
  <xsl:call-template name="count-facet">
    <xsl:with-param name="facet" select="'LinkedData'"/>
    <xsl:with-param name="tree" select="$LinkedData"/>
  </xsl:call-template>

  <xsl:variable name="supplemental_data"
                select="replace(base-uri(),'/data/','/supplemental_data/')"/>
  <xsl:if test="FileUtils:exists($supplemental_data)" >
    <xsl:variable name="data" select="document($supplemental_data)"/>
    <xsl:if test="($data)/s/@dpla">
      <facet-dpla xtf:meta="yes" xtf:store="yes">
        <xsl:text>true</xsl:text>
      </facet-dpla>
    </xsl:if>
    <xsl:if test="($data)/s/@europeana">
      <facet-europeana xtf:meta="yes" xtf:store="yes">
        <xsl:text>true</xsl:text>
      </facet-europeana>
    </xsl:if>
    <xsl:if test="($data)/s/@thumb">
      <facet-wikithumb xtf:meta="yes" xtf:store="yes"
        id="{($data)/s/@n}"
        thumb="{($data)/s/@thumb}"
        rights="{($data)/s/@thumb_rights}">
        <xsl:text>true</xsl:text>
      </facet-wikithumb>
    </xsl:if>
  </xsl:if>


  </xsl:template>

  <xsl:template name="count-facet">
    <xsl:param name="facet" />
    <xsl:param name="tree" />
    <xsl:if test="boolean($tree)">
      <xsl:element name="facet-{$facet}">
        <xsl:attribute name="xtf:meta" select="'yes'"/>
        <xsl:attribute name="xtf:facet" select="'yes'"/>
        <xsl:value-of select="$facet"/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="count-{$facet}">
        <xsl:attribute name="xtf:meta" select="'yes'"/>
        <xsl:value-of select="count($tree)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="eac:cpfRelation[ends-with(@xlink:arcrole,'sameAs')][starts-with(@xlink:href,'http://en.wikipedia.org/wiki/')]" 
                mode="main-facets">
    <facet-Wikipedia xtf:facet="yes" xtf:meta="yes">Wikipedia</facet-Wikipedia>
  </xsl:template>

  <xsl:template
    match="eac:cpfDescription/eac:relations/eac:resourceRelation//mods:name[mods:role/mods:roleTerm='Repository']/mods:namePart | ead:corpname" mode="main-facets">
    <facet-Location xtf:facet="yes" xtf:meta="yes">
    <xsl:choose>
      <xsl:when test=". = 'Unknown'">
        <xsl:apply-templates select="../../mods:recordInfo/mods:recordContentSource" mode="fixup-location"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    </facet-Location>
  </xsl:template>

  <xsl:template match="mods:recordContentSource" mode="fixup-location">
    <xsl:choose>
      <xsl:when test=". = 'ISIL:DLC'">
        <xsl:text>Library of Congress</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Unknown (</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="eac:control" mode="meta">
    <xsl:if test="count(eac:otherRecordId) &gt; 0">
      <recordId-merge xtf:meta="true">true</recordId-merge>
    </xsl:if>
    <xsl:if test="count(eac:otherRecordId[not(@localType='VIAFId')][not(@localType='dbpedia')]) &gt; 0">
      <recordId-eac-merge xtf:meta="true">true</recordId-eac-merge>
    </xsl:if>
    <xsl:apply-templates select="eac:recordId|eac:otherRecordId" mode="meta"/>
  </xsl:template>

  <xsl:template match="eac:recordId|eac:otherRecordId" mode="meta">
    <recordIds xtf:meta="true" xtf:tokenize="no">
      <xsl:value-of select="."/>
    </recordIds>
  </xsl:template>

  <xsl:template match="eac:identity" mode="meta">
    <xsl:apply-templates select="eac:nameEntry" mode="meta"/>
    <xsl:variable name="identity" select="replace(eac:nameEntry[1]/eac:part,'\p{Cc}','')"/>
    <!-- was getting errors sorting on identity from above, creating untokenized -->
    <sort-identity xtf:meta="yes" xtf:tokenize="false">
      <xsl:value-of select="CharUtils:applyAccentMap('../conf/accentFolding/accentMap.txt', $identity)"/>
    </sort-identity>
    <!-- for A .. Z browse -->
    <facet-identityAZ xtf:meta="true" xtf:tokenize="no">
	<xsl:variable name="firstChar" select="upper-case(substring($identity,1,1))"/>
	<xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
        <xsl:text>::</xsl:text>
        <xsl:value-of select="eac:nameEntry[1]/eac:part"/>
    </facet-identityAZ>
    <xsl:element name="facet-{normalize-space(eac:entityType)}">
      <xsl:attribute name="xtf:meta">yes</xsl:attribute>
      <xsl:attribute name="xtf:facet">yes</xsl:attribute>
      <xsl:apply-templates mode="value-of" select="eac:nameEntry[1]/eac:part"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="eac:nameEntry" mode="meta">
    <identity xtf:meta="yes">
      <xsl:apply-templates mode="value-of" select="eac:part"/>
    </identity>
  </xsl:template>

  <xsl:template match="eac:occupation" mode="meta">
    <occupation xtf:meta="yes"><xsl:apply-templates mode="meta" select="eac:term"/></occupation>
    <facet-occupation xtf:facet="yes" xtf:meta="yes"><xsl:apply-templates select="eac:term" mode="meta"/></facet-occupation>
  </xsl:template>

  <xsl:template match="eac:localDescription" mode="meta">
    <localDescription xtf:meta="yes">
      <xsl:apply-templates select="eac:term|eac:placeEntry" mode="meta"/>
    </localDescription>
    <facet-localDescription xtf:facet="yes" xtf:meta="yes">
      <xsl:apply-templates select="eac:term|eac:placeEntry" mode="meta"/>
    </facet-localDescription>
  </xsl:template>

  <xsl:template match="@localType" mode="meta">
    <xsl:value-of select="replace(.,'^VIAF:','')"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="eac:term" mode="meta">
    <xsl:value-of select="replace(replace(.
      ,'[^\w\)]+$','')
      ,'--.*$','')
    "/>
  </xsl:template>

  <xsl:template match="eac:placeEntry" mode="meta">
    <xsl:value-of select="iso:lookup(@countryCode)"/>
  </xsl:template>
  
  <xsl:template match="eac:placeEntry[../eac:localDescription[@localType='VIAF:nationality']]">
    <term><xsl:value-of select="iso:lookup(@countryCode)"/></term>
  </xsl:template>
  
  <xsl:template match="eac:cpfRelation" mode="meta">
    <facet-cpfRelation xtf:facet="yes" xtf:meta="yes"><xsl:value-of select="eac:relationEntry"/></facet-cpfRelation>
  </xsl:template>
  
  <xsl:template match="eac:resourceRelation" mode="meta">
    <facet-resourceRelation xtf:facet="yes" xtf:meta="yes"><xsl:value-of select="eac:relationEntry"/></facet-resourceRelation>
  </xsl:template>

  <xsl:template match="eac:fromDate|eac:toDate|eac:entityId" mode="meta">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:attribute name="xtf:meta">yes</xsl:attribute>
      <xsl:apply-templates select="*|text()"/>
    </xsl:element>
  </xsl:template>

  <!-- don't index objectXMLWrap'ed XML b/c it is not displayed -->
  <xsl:template match="eac:objectXMLWrap">
    <xsl:copy>
      <xsl:attribute name="xtf:index" select="'no'"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- sectionTypes - default mode -->
  <!-- per https://docs.google.com/document/pub?id=1wP9x6sdOZTagJNQXoyJfPh0Y6UzQgqLwLI86WSlIPbk -->
  <!-- sectionTypes -->

  <!-- one level deep 
-->
  <xsl:template match="eac:control|eac:cpfDescription">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType" select="name()"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- two or three levels deep 
-->
  <xsl:template match="eac:description|eac:cpfRelations|eac:existDates|eac:biogHist|eac:generalContext|eac:occupation|eac:localDescription|eac:resourceRelation">
    <xsl:copy>
      <xsl:attribute name="xtf:sectionTypeAdd" select="name()"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eac:relations">
    <xsl:copy>
      <xsl:attribute name="xtf:sectionTypeAdd" select="name()"/>
          <xsl:attribute name="xtf:wordBoost" select="'1.0'"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eac:identity">
    <xsl:copy>
      <xsl:attribute name="xtf:sectionTypeAdd" select="name()"/>
      <xsl:attribute name="xtf:wordBoost" select="'1.5'"/>
      <xsl:variable 
        name="deDuplicateNameEntry" 
        select="eac:nameEntry[not(eac:part=preceding::eac:nameEntry/eac:part)]
      "/>
      <xsl:apply-templates select="@*|eac:descriptiveNote|eac:entityId|eac:entityType|eac:nameEntryParallel|$deDuplicateNameEntry"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eac:language[@languageCode][not(text())]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="iso:langLookup(@languageCode)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eac:part" mode="value-of">
      <xsl:value-of select="replace(.,'\p{Cc}','')"/>
  </xsl:template>

  <xsl:template match="eac:part">
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:for-each select="@*"/>
      <xsl:value-of select="replace(.,'\p{Cc}','')"/>
    </xsl:element>
  </xsl:template>

  <!-- identity transform -->
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
