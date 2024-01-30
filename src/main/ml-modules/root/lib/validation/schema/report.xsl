<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdmp="http://marklogic.com/xdmp"
    xmlns:error="http://marklogic.com/xdmp/error"
    exclude-result-prefixes="xdmp error">

  <xsl:template match="xdmp:validation-errors">
    <xsl:element name="schema-report" namespace="http:koop.overheid.nl/lvbb/opera">
      <xsl:attribute name="count">
        <xsl:value-of select="count(error:error)"/>
      </xsl:attribute>
      <xsl:apply-templates select="error:error"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="error:error">
    <xsl:element name="error" namespace="http:koop.overheid.nl/lvbb/opera" >
      <xsl:apply-templates select="error:format-string"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="error:format-string">
    <xsl:element name="error-message" namespace="http:koop.overheid.nl/lvbb/opera" >
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>