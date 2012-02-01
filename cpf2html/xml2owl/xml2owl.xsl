<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns="urn:isbn:1-931666-33-4" xmlns:eac-cpf="http://archivi.ibc.regione.emilia-romagna.it/ontology/eac-cpf/" xmlns:viaf="http://viaf.org/ontology/1.1/#" xmlns:gn="http://www.geonames.org/ontology#" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
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

-->
  <xsl:output method="xml" version="1.0" encoding="UTF-8"/>
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="eac-cpf">
    <xsl:variable name="id">
      <xsl:value-of select="control/recordId/text()"/>
    </xsl:variable>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns="urn:isbn:1-931666-33-4" xmlns:eac-cpf="http://archivi.ibc.regione.emilia-romagna.it/ontology/eac-cpf/" xmlns:viaf="http://viaf.org/ontology/1.1/#" xmlns:gn="http://www.geonames.org/ontology#" xmlns:xlink="http://www.w3.org/1999/xlink">
      <xsl:variable name="entityType">
        <xsl:value-of select="cpfDescription/identity/entityType/text()"/>
      </xsl:variable>
      <xsl:if test="$entityType='corporateBody'">
        <xsl:element name="eac-cpf:corporateBody">
          <xsl:call-template name="scriviRDF">
            <xsl:with-param name="rdf"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:if>
      <xsl:if test="$entityType='family'">
        <xsl:element name="eac-cpf:family">
          <xsl:call-template name="scriviRDF">
            <xsl:with-param name="rdf"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:if>
      <xsl:if test="$entityType='person'">
        <xsl:element name="eac-cpf:person">
          <xsl:call-template name="scriviRDF">
            <xsl:with-param name="rdf"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:if>
    </rdf:RDF>
  </xsl:template>
  <xsl:template name="scriviRDF">
    <xsl:param name="rdf"/>
    <xsl:attribute name="rdf:about">URI<xsl:value-of select="control/recordId"/></xsl:attribute>
    <xsl:element name="rdfs:label">
      <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
      <xsl:value-of select="cpfDescription/identity/nameEntry/part/text()"/>
      <xsl:if test="cpfDescription/description/existDates">, <xsl:value-of select="substring(cpfDescription/description/existDates/date/@standardDate,1,4)"/>-<xsl:value-of select="substring(cpfDescription/description/existDates/date/@standardDate,10,4)"/>
			</xsl:if>
    </xsl:element>
<!-- foaf:page, foaf:depiction, owl:sameAs per viaf, gn:Feature -->
    <xsl:if test="cpfDescription/description/existDates">
      <xsl:element name="dc:date">
        <xsl:value-of select="cpfDescription/description/existDates/date/@standardDate"/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="owl:sameAs">
      <xsl:attribute name="rdf:resource">http://viaf.org/viaf/</xsl:attribute>
    </xsl:element>
    <xsl:if test="control">
      <xsl:element name="eac-cpf:control">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>Identificazione Soggetto Produttore <xsl:value-of select="cpfDescription/identity/nameEntry/part/text()"/></xsl:element>
        <xsl:element name="eac-cpf:recordID">
          <xsl:value-of select="control/recordId"/>
        </xsl:element>
        <xsl:if test="control/otherRecordId">
          <xsl:for-each select="control/otherRecordId">
            <xsl:element name="eac-cpf:otherRecordID">
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="control/maintenanceStatus">
          <xsl:element name="eac-cpf:maintenanceStatus">
            <xsl:value-of select="control/maintenanceStatus"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="control/publicationStatus">
          <xsl:element name="eac-cpf:publicationStatus">
            <xsl:value-of select="control/publicationStatus"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="control/maintenanceAgency">
          <xsl:element name="eac-cpf:maintenanceAgency">
            <xsl:value-of select="control/maintenanceAgency/agencyName/text()"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="control/languageDeclaration">
          <xsl:element name="eac-cpf:languageDeclaration">
            <xsl:value-of select="control/languageDeclaration/language/text()"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="control/conventionDeclaration">
          <xsl:element name="eac-cpf:conventionDeclaration">
            <xsl:value-of select="control/conventionDeclaration/citation/text()"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="control/sources">
          <xsl:choose>
            <xsl:when test="not(control/sources/source/@xlink:href)">
              <xsl:for-each select="control/sources/source">
                <xsl:element name="eac-cpf:source">
                  <xsl:value-of select="sourceEntry"/>
                </xsl:element>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="control/sources/source[@xlink:href]">
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
    <xsl:if test="cpfDescription">
      <xsl:element name="eac-cpf:description">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:for-each select="cpfDescription/identity/nameEntry">
          <xsl:element name="eac-cpf:nameEntry">
            <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
            <xsl:element name="foaf:name">
              <xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang"/>
              </xsl:attribute>
              <xsl:value-of select="part/text()"/>
            </xsl:element>
            <xsl:if test="authorizedForm">
              <xsl:element name="eac-cpf:authorizedForm">
                <xsl:value-of select="authorizedForm/text()"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="alternativeForm">
              <xsl:element name="eac-cpf:alternativeForm">
                <xsl:value-of select="alternativeForm/text()"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="@localType">
              <xsl:element name="dcterms:conformsTo">
                <xsl:value-of select="@localType"/>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:for-each>
        <xsl:if test="cpfDescription/description/existDates/date/@standardDate">
          <xsl:element name="eac-cpf:existDates">
            <xsl:value-of select="cpfDescription/description/existDates/date/@standardDate"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="cpfDescription/description/existDates/dateRange">
          <xsl:element name="eac-cpf:existDates">
            <xsl:value-of select="cpfDescription/description/existDates/dateRange/fromDate"/>
            <xsl:if test="cpfDescription/description/existDates/dateRange/toDate">/<xsl:value-of select="cpfDescription/description/existDates/dateRange/toDate"/>
						</xsl:if>
          </xsl:element>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="cpfDescription/description/localDescription[@localType='subject']">
            <xsl:for-each select="cpfDescription/description/localDescription[@localType='subject']">
              <xsl:element name="dc:subject">
                <xsl:value-of select="term/text()"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="cpfDescription/description/places">
          <xsl:for-each select="cpfDescription/description/places/place">
            <xsl:choose>
              <xsl:when test="contains(descriptiveNote/p,'nascita')">
                <xsl:element name="bio:Birth">
                  <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                  <xsl:element name="bio:date">
                    <xsl:value-of select="substring-before(../../existDates,'-')"/>
                  </xsl:element>
                  <xsl:if test="placeEntry">
                    <xsl:element name="gn:Feature">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="eac-cpf:place">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:when>
              <xsl:when test="contains(descriptiveNote/p,'morte')">
                <xsl:element name="bio:Death">
                  <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                  <xsl:element name="bio:date">
                    <xsl:value-of select="substring-after(../../existDates,'-')"/>
                  </xsl:element>
                  <xsl:if test="placeEntry">
                    <xsl:element name="gn:Feature">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="eac-cpf:place">
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="placeEntry"/>
                      </xsl:attribute>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:when>
              <xsl:when test="descriptiveNote/p/text()='sede'">
                <xsl:if test="placeEntry">
                  <xsl:element name="gn:Feature">
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="placeEntry"/>
                    </xsl:attribute>
                  </xsl:element>
                  <xsl:element name="eac-cpf:place">
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="placeEntry"/>
                    </xsl:attribute>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="cpfDescription/description/biogHist">
          <xsl:element name="eac-cpf:biogHist">
            <xsl:apply-templates select="cpfDescription/description/biogHist"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="cpfDescription/description/occupation">
          <xsl:for-each select="cpfDescription/description/occupation">
            <xsl:element name="eac-cpf:occupation">
              <xsl:value-of select="term/text()"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:if>
      </xsl:element>
      <xsl:if test="cpfDescription/relations">
        <xsl:for-each select="cpfDescription/relations/cpfRelation">
          <xsl:element name="eac-cpf:cpfRelation">
            <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
            <xsl:choose>
              <xsl:when test="@cpfRelationType">
                <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../identity/nameEntry/part[@localType='normal']"/> <xsl:value-of select="@cpfRelationType"/> relation with <xsl:value-of select="relationEntry/text()"/></xsl:element>
                <xsl:element name="eac-cpf:cpfRelationType">
                  <xsl:value-of select="@cpfRelationType"/>
                </xsl:element>
                <xsl:if test="descriptiveNote/p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="descriptiveNote/p/text()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@xlink:arcrole">
                <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../identity/nameEntry[1]/part"/> <xsl:value-of select="@xlink:arcrole"/> <xsl:value-of select="relationEntry/text()"/></xsl:element>
                <xsl:element name="eac-cpf:cpfRelationType">
                  <xsl:value-of select="@xlink:arcrole"/>
                </xsl:element>
                <xsl:if test="descriptiveNote/p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="descriptiveNote/p/text()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
            <xsl:element name="dcterms:relation">
              <xsl:attribute name="rdf:resource">http://archivi.ibc.regione.emilia-romagna.it/eac-cpf/<xsl:value-of select="relationEntry/@localType"/></xsl:attribute>
            </xsl:element>
            <xsl:if test="date">
              <xsl:element name="dc:date">
                <xsl:value-of select="date"/>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="cpfDescription/relations/resourceRelation">
          <xsl:choose>
            <xsl:when test="@resourceRelationType">
              <xsl:element name="eac-cpf:resourceRelation">
                <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                <xsl:element name="rdfs:label">
                  <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
                  <xsl:if test="@resourceRelationType='creatorOf'"><xsl:value-of select="../../identity/nameEntry/part[@localType='normal']"/>  creator of <xsl:value-of select="relationEntry/text()"/></xsl:if>
                  <xsl:if test="@resourceRelationType='other'"><xsl:value-of select="../../identity/nameEntry/part[@localType='normal']"/>  in relation with <xsl:value-of select="relationEntry/text()"/></xsl:if>
                </xsl:element>
                <xsl:element name="eac-cpf:resourceRelationType">
                  <xsl:value-of select="@resourceRelationType"/>
                </xsl:element>
                <xsl:if test="descriptiveNote/p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="descriptiveNote/p/text()"/>
                  </xsl:element>
                </xsl:if>
                <xsl:element name="dcterms:relation">
                  <xsl:attribute name="rdf:resource">http://archivi.ibc.regione.emilia-romagna.it/ead-str/<xsl:value-of select="relationEntry/@localType"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="date">
                  <xsl:element name="dc:date">
                    <xsl:value-of select="date"/>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:when>
            <xsl:when test="@xlink:arcrole">
              <xsl:element name="eac-cpf:resourceRelation">
                <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
                <xsl:element name="rdfs:label"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../identity/nameEntry[1]/part"/> <xsl:value-of select="@xlink:arcrole"/> <xsl:value-of select="relationEntry/text()"/></xsl:element>
                <xsl:element name="eac-cpf:resourceRelationType">
                  <xsl:value-of select="@xlink:arcrole"/>
                </xsl:element>
                <xsl:if test="descriptiveNote/p">
                  <xsl:element name="dc:description">
                    <xsl:value-of select="descriptiveNote/p/text()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
<!-- controllare -->
        <xsl:for-each select="cpfDescription/relations/functionRelation">
          <xsl:element name="eac-cpf:functionRelation">
            <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
            <xsl:element name="rdfs:label">
              <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
              <xsl:if test="@functionRelationType='controls'"><xsl:value-of select="../../identity/nameEntry/part[@localType='normal']"/>  creator of <xsl:value-of select="relationEntry/text()"/></xsl:if>
              <xsl:if test="@functionRelationType='owns'"><xsl:value-of select="../../identity/nameEntry/part[@localType='normal']"/>  creator of <xsl:value-of select="relationEntry/text()"/></xsl:if>
              <xsl:if test="@functionRelationType='performs'"><xsl:value-of select="../../identity/nameEntry/part[@localType='normal']"/>  creator of <xsl:value-of select="relationEntry/text()"/></xsl:if>
            </xsl:element>
            <xsl:element name="eac-cpf:functionRelationType">
              <xsl:value-of select="@functionRelationType"/>
            </xsl:element>
            <xsl:if test="descriptiveNote/p">
              <xsl:element name="dc:description">
                <xsl:value-of select="descriptiveNote/p/text()"/>
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
      <xsl:element name="skos:changeNote">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:element name="dc:date">
          <xsl:value-of select="control/maintenanceHistory/maintenanceEvent[child::eventType='create']/eventDateTime/text()"/>
        </xsl:element>
        <xsl:element name="dc:creator">IBC</xsl:element>
        <xsl:element name="rdf:value">create</xsl:element>
      </xsl:element>
      <xsl:element name="dc:identifier">
        <xsl:value-of select="control/recordId"/>
      </xsl:element>
      <xsl:element name="dc:creator">
        <xsl:value-of select="control/maintenanceHistory/maintenanceEvent[child::eventType='create']/agent"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match="cpfDescription/description/biogHist">
    <xsl:if test="p">
      <xsl:apply-templates/>
    </xsl:if>
    <xsl:if test="chronList">
      <xsl:for-each select="chronList/chronItem"><xsl:if test="date"><xsl:value-of select="date"/>: </xsl:if><xsl:value-of select="normalize-space(event)"/>; 
			</xsl:for-each>
    </xsl:if>
  </xsl:template>
  <xsl:template match="p">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
