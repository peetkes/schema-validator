<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:opera="http://koop.overheid.nl/lvbb/opera"
      xmlns:aanl="https://standaarden.overheid.nl/lvbb/stop/aanlevering/"
      xmlns:data="https://standaarden.overheid.nl/stop/data"
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
        <opera:idAanleveraar><xsl:value-of select="$idAanleveraar"/></opera:idAanleveraar>
        <opera:idLevering><xsl:value-of select="$idLevering"/></opera:idLevering>
        <opera:idBevoegdGezag><xsl:value-of select="$idBevoegdGezag"/></opera:idBevoegdGezag>
      </opera:header>
      <opera:instance>
        <xsl:copy-of select="."/>
      </opera:instance>
    </opera:envelope>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>