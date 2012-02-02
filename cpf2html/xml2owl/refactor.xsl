<?xml version="1.0" encoding="UTF-8"?>
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
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="xsl:element[not(contains(@name,'{'))]">
    <xsl:element name="{@name}">
      <xsl:apply-templates select="xsl:attribute"/>
      <xsl:apply-templates select="*[not(name(.)='xsl:attribute')]"/>
    </xsl:element>
  </xsl:template>

  <!-- xsl:template match="xsl:attribute">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template -->

  <!-- identity transform copies HTML from the layout file -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
