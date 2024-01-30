<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:opera="http://koop.overheid.nl/lvbb/opera"
      xmlns:aanl="https://standaarden.overheid.nl/lvbb/stop/aanlevering/"
      xmlns:data="https://standaarden.overheid.nl/stop/imop/data/"
      exclude-result-prefixes="#all"
      version="2.0">

  <xsl:param name="root" select="'dummy'"/>
  <xsl:param name="idAanleveraar" select="'dummy'"/>
  <xsl:param name="idLevering" select="'dummy'"/>
  <xsl:param name="idBevoegdGezag" select="'dummy'"/>

  <xsl:template match="*[local-name() eq $root]">
    <opera:envelope>
      <opera:header>
        <opera:root><xsl:value-of select="local-name()"/></opera:root>
        <opera:schemaVersion><xsl:value-of select="@schemaversie"/></opera:schemaVersion>
        <opera:idAanleveraar><xsl:value-of select="$idAanleveraar"/></opera:idAanleveraar>
        <opera:idLevering><xsl:value-of select="$idLevering"/></opera:idLevering>
        <opera:idBevoegdGezag><xsl:value-of select="$idBevoegdGezag"/></opera:idBevoegdGezag>
        <xsl:apply-templates select="aanl:BesluitVersie|aanl:InformatieObjectVersie|aanl:KennisgevingVersie" mode="metadata"/>
      </opera:header>
      <opera:instance>
        <xsl:copy-of select="."/>
      </opera:instance>
    </opera:envelope>
  </xsl:template>

  <xsl:template match="aanl:BesluitVersie|aanl:InformatieObjectVersie|aanl:KennisgevingVersie" mode="metadata">
    <xsl:apply-templates select="data:ExpressionIdentificatie" mode="metadata"/>
    <xsl:apply-templates select="data:BesluitMetadata|data:KennisgevingMetadata|data:InformatieObjectMetadata" mode="metadata"/>
  </xsl:template>

  <xsl:template match="data:ExpressionIdentificatie" mode="metadata">
    <opera:identification>
      <xsl:apply-templates mode="metadata"/>
    </opera:identification>
  </xsl:template>

  <xsl:template match="data:BesluitMetadata|data:KennisgevingMetadata|data:InformatieObjectMetadata" mode="metadata">
    <opera:metadata>
      <xsl:apply-templates mode="metadata"/>
    </opera:metadata>
  </xsl:template>

  <xsl:template match="data:FRBRWork" mode="metadata">
    <opera:work><xsl:value-of select="."/></opera:work>
  </xsl:template>

  <xsl:template match="data:FRBRExpression" mode="metadata">
    <opera:expression><xsl:value-of select="."/></opera:expression>
  </xsl:template>

  <xsl:template match="data:soortWork" mode="metadata">
    <opera:type><xsl:value-of select="."/></opera:type>
  </xsl:template>

  <xsl:template match="data:eindverantwoordelijke" mode="metadata">
    <opera:eindverantwoordelijke><xsl:value-of select="."/></opera:eindverantwoordelijke>
  </xsl:template>

  <xsl:template match="data:maker" mode="metadata">
    <opera:maker><xsl:value-of select="."/></opera:maker>
  </xsl:template>

  <xsl:template match="data:officieleTitel" mode="metadata">
    <opera:officieleTitel><xsl:value-of select="."/></opera:officieleTitel>
  </xsl:template>

  <xsl:template match="data:opvolging" mode="metadata">
    <xsl:for-each select="data:opvolgerVan">
      <opera:opvolgerVan><xsl:value-of select="."/></opera:opvolgerVan>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="data:soortKennisgeving" mode="metadata">
    <opera:soortKennisgeving><xsl:value-of select="."/></opera:soortKennisgeving>
  </xsl:template>

  <xsl:template match="data:mededelingOver" mode="metadata">
    <opera:mededelingOver><xsl:value-of select="."/></opera:mededelingOver>
  </xsl:template>

  <xsl:template match="data:publicatieInstructie" mode="metadata">
    <opera:publicatieInstructie><xsl:value-of select="."/></opera:publicatieInstructie>
  </xsl:template>

  <xsl:template match="data:formaatInformatieObject" mode="metadata">
    <opera:formaatInformatieObject><xsl:value-of select="."/></opera:formaatInformatieObject>
  </xsl:template>

  <xsl:template match="data:soortProcedure" mode="metadata">
    <opera:soortProcedure><xsl:value-of select="."/></opera:soortProcedure>
  </xsl:template>

  <xsl:template match="data:soortBestuursorgaan" mode="metadata">
    <opera:soortBestuursorgaan><xsl:value-of select="."/></opera:soortBestuursorgaan>
  </xsl:template>

  <xsl:template match="*" mode="metadata"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>