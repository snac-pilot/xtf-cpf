<?xml version="1.0" encoding="UTF-8"?>
<!-- # convert EAC XML to RDF 
[this file on google code](http://code.google.com/p/xtf-cpf/source/browse/cpf2html/xml2owl/xml2owl.xsl?name=xtf-cpf) 
 -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dcterms="http://purl.org/dc/terms/" 
  xmlns:owl="http://www.w3.org/2002/07/owl#" 
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:skos="http://www.w3.org/2008/05/skos#" 
  xmlns:foaf="http://xmlns.com/foaf/0.1/" 
  xmlns:bio="http://purl.org/vocab/bio/0.1/" 
  xmlns="urn:isbn:1-931666-33-4" 
  xmlns:eax="urn:isbn:1-931666-33-4" 
  xmlns:eac-cpf="http://archivi.ibc.regione.emilia-romagna.it/ontology/eac-cpf/" 
  xmlns:viaf="http://viaf.org/ontology/1.1/#" 
  xmlns:gn="http://www.geonames.org/ontology#" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  version="1.0"
>
<!--
Created by Silvia Mazzini, Regesta.exe, 2011

Copyright (c) 2011, Regesta.exe
All rights reserved.

Redistribution and use are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Eduserv nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

### Related Work

[EAC-CPF Ontology and Linked Archival Data](http://ceur-ws.org/Vol-801/paper6.pdf)
Proceedings of the 1st International Workshop on Semantic Digital Archives (SDA 2011)

[eac-cpf ontology browser](http://templates.xdams.net/RelationBrowser/genericEAC/RelationBrowserCIA.html)

[Epimorphics Linked Data API Implementation](http://code.google.com/p/elda/)  
a java implementation of the 
[Linked Data API](http://code.google.com/p/linked-data-api/)

-->
<!-- 

### Social Network and Archival Context
Modified by Brian Tingle for the [Social Networks and Archival 
Context Project](http://socialarchive.iath.virginia.edu/ )
Sponsored by the National Endowment for the Humanaties http://www.neh.gov/

-->
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <!-- supplied by XTF -->
  <xsl:param name="docId"/>

  <!-- root template -->
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- I could not get this to work in the default namespace; 
       choose eax: for the xml; eac-cpf is the RDF's namespace ~bt -->
  <xsl:template match="eax:eac-cpf">
    <!-- root rdf element -->
    <rdf:RDF 
       xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
       xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
       xmlns:dc="http://purl.org/dc/elements/1.1/"
       xmlns:dcterms="http://purl.org/dc/terms/"
       xmlns:owl="http://www.w3.org/2002/07/owl#"
       xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:skos="http://www.w3.org/2008/05/skos#"
       xmlns:foaf="http://xmlns.com/foaf/0.1/"
       xmlns:bio="http://purl.org/vocab/bio/0.1/"
       xmlns="urn:isbn:1-931666-33-4"
       xmlns:eac-cpf="http://archivi.ibc.regione.emilia-romagna.it/ontology/eac-cpf/"
       xmlns:viaf="http://viaf.org/ontology/1.1/#"
       xmlns:gn="http://www.geonames.org/ontology#"
       xmlns:xlink="http://www.w3.org/1999/xlink"
    > 
      <xsl:variable name="entityType">
        <xsl:value-of select="eax:cpfDescription/eax:identity/eax:entityType"/>
      </xsl:variable>
      <xsl:element name="eac-cpf:{$entityType}">
        <xsl:attribute name="rdf:about">
          <xsl:text>http://socialarchive.iath.virginia.edu/xtf/view?docId=</xsl:text>
          <xsl:value-of select="$docId"/>
          <xsl:text>#entity</xsl:text>
        </xsl:attribute>
          <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
            <xsl:value-of select="eax:cpfDescription/eax:identity/eax:nameEntry/eax:part"/>
      <!-- this definatly should be refactored -->
      <xsl:if test="eax:cpfDescription/eax:description/eax:existDates">, <xsl:value-of select="substring(eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate,1,4)"/>-<xsl:value-of select="substring(eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate,10,4)"/>
			</xsl:if>
    </rdfs:label>
<!-- `foaf:page, foaf:depiction, owl:sameAs per viaf, gn:Feature` -->
    <!-- dates -->
    <xsl:if test="eax:cpfDescription/eax:description/eax:existDates">
      <xsl:element name="dc:date">
        <xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate"/>
      </xsl:element>
    </xsl:if>

    <!-- viaf --><!-- add dbpedia as well -->
    <!--
```
    <xsl:element name="owl:sameAs">
      <xsl:attribute name="rdf:resource">http://viaf.org/viaf/</xsl:attribute>
    </xsl:element>
```-->

    <!-- ## control -->
    <xsl:if test="eax:control">
      <xsl:element name="eac-cpf:control">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>Identificazione Soggetto Produttore <xsl:value-of select="eax:cpfDescription/eax:identity/eax:nameEntry/eax:part/text()"/></xsl:element>
        <xsl:element name="eac-cpf:recordID">
          <xsl:value-of select="eax:control/eax:recordId"/>
        </xsl:element>
        <xsl:if test="eax:control/eax:otherRecordId">
          <xsl:for-each select="eax:control/eax:otherRecordId">
            <xsl:element name="eac-cpf:otherRecordID">
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="eax:control/eax:maintenanceStatus">
          <xsl:element name="eac-cpf:maintenanceStatus">
            <xsl:value-of select="eax:control/eax:maintenanceStatus"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:control/eax:publicationStatus">
          <xsl:element name="eac-cpf:publicationStatus">
            <xsl:value-of select="eax:control/eax:publicationStatus"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:control/eax:maintenanceAgency">
          <xsl:element name="eac-cpf:maintenanceAgency">
            <xsl:value-of select="eax:control/eax:maintenanceAgency/eax:agencyName/text()"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:control/eax:languageDeclaration">
          <xsl:element name="eac-cpf:languageDeclaration">
            <xsl:value-of select="eax:control/eax:languageDeclaration/eax:language/text()"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:control/eax:conventionDeclaration">
          <xsl:element name="eac-cpf:conventionDeclaration">
            <xsl:value-of select="eax:control/eax:conventionDeclaration/eax:citation/text()"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:control/eax:sources">
          <xsl:choose>
            <xsl:when test="not(eax:control/eax:sources/eax:source/@xlink:href)">
              <xsl:for-each select="eax:control/eax:sources/eax:source">
                <xsl:element name="eac-cpf:source">
                  <xsl:value-of select="eax:sourceEntry"/>
                </xsl:element>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="eax:control/eax:sources/eax:source[@xlink:href]">
                <xsl:element name="dcterms:source">
                  <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="@xlink:href"/>
                  </xsl:attribute>
                </xsl:element>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:element>
    </xsl:if>
    <!-- ## cpfDescription -->
    <xsl:if test="eax:cpfDescription">
      <xsl:element name="eac-cpf:description">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:for-each select="eax:cpfDescription/eax:identity/eax:nameEntry">
          <xsl:element name="eac-cpf:nameEntry">
            <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
            <xsl:element name="foaf:name">
              <xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang"/>
              </xsl:attribute>
              <xsl:value-of select="eax:part/text()"/>
            </xsl:element>
            <xsl:if test="eax:authorizedForm">
              <xsl:element name="eac-cpf:authorizedForm">
                <xsl:value-of select="eax:authorizedForm/text()"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="eax:alternativeForm">
              <xsl:element name="eac-cpf:alternativeForm">
                <xsl:value-of select="eax:alternativeForm/text()"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="@localType">
              <xsl:element name="dcterms:conformsTo">
                <xsl:value-of select="@localType"/>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:for-each>
        <xsl:if test="eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate">
          <xsl:element name="eac-cpf:existDates">
            <xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange">
          <xsl:element name="eac-cpf:existDates">
            <xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange/eax:fromDate"/>
            <xsl:if test="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange/eax:toDate">/<xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange/eax:toDate"/>
						</xsl:if>
          </xsl:element>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="eax:cpfDescription/eax:description/eax:localDescription[@localType='subject']">
            <xsl:for-each select="eax:cpfDescription/eax:description/eax:localDescription[@localType='subject']">
              <xsl:element name="dc:subject">
                <xsl:value-of select="eax:term/text()"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="eax:cpfDescription/eax:description/eax:places">
          <xsl:for-each select="eax:cpfDescription/eax:description/eax:places/eax:place">
            <xsl:choose>
              <xsl:when test="contains(eax:descriptiveNote/eax:p,'nascita')">
                <xsl:element name="bio:Birth">
                  <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                  <xsl:element name="bio:date">
                    <xsl:value-of select="substring-before(../../eax:existDates,'-')"/>
                  </xsl:element>
                  <xsl:if test="eax:placeEntry">
                    <xsl:element name="gn:Feature">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="eac-cpf:place">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:when>
              <xsl:when test="contains(eax:descriptiveNote/eax:p,'morte')">
                <xsl:element name="bio:Death">
                  <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                  <xsl:element name="bio:date">
                    <xsl:value-of select="substring-after(../../eax:existDates,'-')"/>
                  </xsl:element>
                  <xsl:if test="eax:placeEntry">
                    <xsl:element name="gn:Feature">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="eac-cpf:place">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:when>
              <xsl:when test="eax:descriptiveNote/eax:p/text()='sede'">
                <xsl:if test="eax:placeEntry">
                  <xsl:element name="gn:Feature">
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="eax:placeEntry"/>
                    </xsl:attribute>
                  </xsl:element>
                  <xsl:element name="eac-cpf:place">
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="eax:placeEntry"/>
                    </xsl:attribute>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="eax:cpfDescription/eax:description/eax:biogHist">
          <xsl:element name="eac-cpf:biogHist">
            <xsl:apply-templates select="eax:cpfDescription/eax:description/eax:biogHist"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="eax:cpfDescription/eax:description/eax:occupation">
          <xsl:for-each select="eax:cpfDescription/eax:description/eax:occupation">
            <xsl:element name="eac-cpf:occupation">
              <xsl:value-of select="term/text()"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:if>
      </xsl:element>
      <xsl:if test="eax:cpfDescription/eax:relations">
        <xsl:for-each select="eax:cpfDescription/eax:relations/eax:cpfRelation">
          <xsl:element name="eac-cpf:cpfRelation">
            <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
            <xsl:choose>
              <xsl:when test="@cpfRelationType">
                <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/> <xsl:value-of select="@cpfRelationType"/> relation with <xsl:value-of select="eax:relationEntry/text()"/></xsl:element>
                <xsl:element name="eac-cpf:cpfRelationType">
                  <xsl:value-of select="@cpfRelationType"/>
                </xsl:element>
                <xsl:if test="eax:descriptiveNote/eax:p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="eax:descriptiveNote/eax:p/text()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@xlink:arcrole">
                <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../eax:identity/eax:nameEntry[1]/eax:part"/> <xsl:value-of select="@xlink:arcrole"/> <xsl:value-of select="eax:relationEntry/text()"/></xsl:element>
                <xsl:element name="eac-cpf:cpfRelationType">
                  <xsl:value-of select="@xlink:arcrole"/>
                </xsl:element>
                <xsl:if test="eax:descriptiveNote/eax:p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="eax:descriptiveNote/eax:p/text()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
            <xsl:element name="dcterms:relation">
              <xsl:attribute name="rdf:resource">http://archivi.ibc.regione.emilia-romagna.it/eac-cpf/<xsl:value-of select="eax:relationEntry/@localType"/></xsl:attribute>
            </xsl:element>
            <xsl:if test="date">
              <xsl:element name="dc:date">
                <xsl:value-of select="date"/>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="eax:cpfDescription/eax:relations/eax:resourceRelation">
          <xsl:choose>
            <xsl:when test="@resourceRelationType">
              <xsl:element name="eac-cpf:resourceRelation">
                <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                <xsl:element name="rdfs:label">
                  <xsl:attribute name="rdf:datatype">
                     <xsl:text>http://www.w3.org/2001/XMLSchema#string</xsl:text>
                  </xsl:attribute>
                  <xsl:if test="@resourceRelationType='creatorOf'">
                    <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>
                    <xsl:text>  creator of </xsl:text>
                    <xsl:value-of select="eax:relationEntry/text()"/>
                  </xsl:if>
                  <xsl:if test="@resourceRelationType='other'">
                    <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>
                    <xsl:text>  in relation with </xsl:text>
                    <xsl:value-of select="eax:relationEntry/text()"/>
                  </xsl:if>
                </xsl:element>
                <xsl:element name="eac-cpf:resourceRelationType">
                  <xsl:value-of select="@resourceRelationType"/>
                </xsl:element>
                <xsl:if test="eax:descriptiveNote/eax:p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="eax:descriptiveNote/eax:p/text()"/>
                  </xsl:element>
                </xsl:if>
                <!-- xsl:element name="dcterms:relation">
                </xsl:element -->
                <xsl:if test="eax:date">
                  <xsl:element name="dc:date">
                    <xsl:value-of select="eax:date"/>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:when>
            <xsl:when test="@xlink:arcrole">
              <xsl:element name="eac-cpf:resourceRelation">
                <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                <xsl:element name="rdfs:label">
                  <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#string</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="../../eax:identity/eax:nameEntry[1]/eax:part"/>                  <xsl:value-of select="@xlink:arcrole"/>
                  <xsl:value-of select="eax:relationEntry/text()"/>
                </xsl:element>
                <xsl:element name="eac-cpf:resourceRelationType">
                  <xsl:value-of select="@xlink:arcrole"/>
                </xsl:element>
                <xsl:if test="eax:descriptiveNote/eax:p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="eax:descriptiveNote/eax:p/text()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
<!-- controllare -->
        <xsl:for-each select="eax:cpfDescription/eax:relations/eax:functionRelation">
          <xsl:element name="eac-cpf:functionRelation">
            <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
<!-- need to come back here and finsh converting this to xsl:text -->
            <xsl:element name="rdfs:label">
              <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
              <xsl:if test="@functionRelationType='controls'">
                <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>  creator of 
                <xsl:value-of select="eax:relationEntry/text()"/>
              </xsl:if>
              <xsl:if test="@functionRelationType='owns'">
                <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>  creator of 
                <xsl:value-of select="eax:relationEntry/text()"/>
              </xsl:if>
              <xsl:if test="@functionRelationType='performs'">
                <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>  creator of 
              <xsl:value-of select="eax:relationEntry/text()"/>
            </xsl:if>
            </xsl:element>
            <xsl:element name="eac-cpf:functionRelationType">
              <xsl:value-of select="@functionRelationType"/>
            </xsl:element>
            <xsl:if test="eax:descriptiveNote/eax:p">
              <xsl:element name="dc:description">
                <xsl:value-of select="eax:descriptiveNote/eax:p/text()"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="date">
              <xsl:element name="dc:date">
                <xsl:value-of select="date"/>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
<!-- not sure if we want this yet -->
      <xsl:element name="skos:changeNote">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:element name="dc:date">
          <xsl:value-of select="eax:control/eax:maintenanceHistory/eax:maintenanceEvent[child::eventType='create']/eax:eventDateTime/text()"/>
        </xsl:element>
        <xsl:element name="dc:creator">IBC</xsl:element>
        <xsl:element name="rdf:value">create</xsl:element>
      </xsl:element>
      <xsl:element name="dc:identifier">
        <xsl:value-of select="eax:control/eax:recordId"/>
      </xsl:element>
      <xsl:element name="dc:creator">
        <xsl:value-of select="eax:control/eax:maintenanceHistory/eax:maintenanceEvent[child::eventType='create']/eax:agent"/>
      </xsl:element>
    </xsl:if>

      </xsl:element>
    </rdf:RDF>
  </xsl:template>


  <!-- bioghist -->
  <xsl:template match="eax:cpfDescription/eax:description/eax:biogHist">
    <xsl:if test="eax:p">
      <xsl:apply-templates/>
    </xsl:if>
    <!-- refactor to apply templates -->
    <xsl:if test="eax:chronList">
      <xsl:for-each select="eax:chronList/eax:chronItem">
        <xsl:if test="eax:date">
          <xsl:value-of select="eax:date"/>
          <xsl:text>: </xsl:text>
        </xsl:if>
      </xsl:for-each>
        <xsl:value-of select="normalize-space(eax:event)"/>; 
    </xsl:if>
  </xsl:template>
  <xsl:template match="eax:p">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
