<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdmp="http://marklogic.com/xdmp"
    xmlns:opera="http:koop.overheid.nl/lvbb/opera"
    xmlns:util="http://marklogic.com/schema-validator/lib/stylesheets/utilities"
    extension-element-prefixes="xdmp"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    exclude-result-prefixes="#all">

  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/stylesheets/utilities" href="/lib/stylesheets/utilities.xqy"/>

  <xsl:output indent="no" omit-xml-declaration="yes"/>

  <xsl:variable name="json-pattern">(\{.*\}).?</xsl:variable>
  <xsl:variable name="message-pattern">(.*?)##@##</xsl:variable>
  <xsl:variable name="code-pattern">(.*?)#\$#@#\$#(.*)</xsl:variable>

  <xsl:template match="svrl:schematron-output">
    <xsl:element name="schematron-report" namespace="http:koop.overheid.nl/lvbb/opera">
      <xsl:if test="exists(svrl:failed-assert[@role='fout' or not(@role)]) or exists(svrl:successful-report[@role='fout' or not(@role)])">
        <xsl:attribute name="errors">
          <xsl:value-of select="count((svrl:failed-assert[@role='fout' or not(@role)]/svrl:text, svrl:successful-report[@role='fout' or not(@role)]/svrl:text))"/>
        </xsl:attribute>
        <xsl:element name="errors" namespace="http:koop.overheid.nl/lvbb/opera">
          <xsl:apply-templates select="svrl:failed-assert[@role='fout' or not(@role)][1]"/>
          <xsl:apply-templates select="svrl:successful-report[@role='fout' or not(@role)][1]"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="exists(svrl:failed-assert[@role='waarschuwing']) or exists(svrl:successful-report[@role='waarschuwing'])">
        <xsl:attribute name="warnings">
          <xsl:value-of select="count((svrl:failed-assert[@role='waarschuwing']/svrl:text,svrl:successful-report[@role='waarschuwing']/svrl:text))"/>
        </xsl:attribute>
        <xsl:element name="warnings" namespace="http:koop.overheid.nl/lvbb/opera">
          <xsl:apply-templates select="svrl:failed-assert[@role='waarschuwing'][1]"/>
          <xsl:apply-templates select="svrl:successful-report[@role='waarschuwing'][1]"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="svrl:failed-assert[@role = 'fout' or not(@role)][1]">
    <xsl:apply-templates select="svrl:text"/>
    <xsl:apply-templates select="following-sibling::svrl:failed-assert[@role = 'fout' or not(@role)]/svrl:text"/>
  </xsl:template>
  <xsl:template match="svrl:failed-assert[@role = 'waarschuwing'][1]">
    <xsl:apply-templates select="svrl:text"/>
    <xsl:apply-templates select="following-sibling::svrl:failed-assert[@role = 'waarschuwing']/svrl:text"/>
  </xsl:template>

  <xsl:template match="svrl:successful-report[@role = 'fout' or not(@role)][1]">
    <xsl:apply-templates select="svrl:text"/>
    <xsl:apply-templates select="following-sibling::svrl:successful-report[@role = 'fout' or not(@role)]/svrl:text"/>
  </xsl:template>
  <xsl:template match="svrl:successful-report[@role = 'waarschuwing'][1]">
    <xsl:apply-templates select="svrl:text"/>
    <xsl:apply-templates select="following-sibling::svrl:successful-report[@role = 'waarschuwing']/svrl:text"/>
  </xsl:template>

  <xsl:template match="svrl:text">
    <xsl:variable name="content" select="."/>
    <xsl:element name="error" namespace="http:koop.overheid.nl/lvbb/opera">
      <xsl:choose>
        <xsl:when test="matches($content, $message-pattern)">
          <xsl:analyze-string select="$content" regex="{$message-pattern}">
            <xsl:matching-substring>
              <xsl:call-template name="filterString">
                <xsl:with-param name="inputString" select="regex-group(1)"/>
                <xsl:with-param name="pattern" select="$code-pattern"/>
              </xsl:call-template>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:call-template name="filterString">
                <xsl:with-param name="inputString" select="current()"/>
                <xsl:with-param name="pattern" select="$code-pattern"/>
              </xsl:call-template>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="matches($content, $code-pattern)">
          <xsl:call-template name="filterString">
            <xsl:with-param name="inputString" select="$content"/>
            <xsl:with-param name="pattern" select="$code-pattern"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="matches($content, $json-pattern)">
          <xsl:variable name="result" select="util:convert-json-string-to-xml($content)"/>
          <xsl:copy-of select="$result"/>
        </xsl:when>
        <xsl:otherwise>
          <opera:error>
            <xsl:value-of select="$content"/>
          </opera:error>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="filterString">
    <xsl:param name="inputString"/>
    <xsl:param name="pattern"/>

    <xsl:analyze-string select="$inputString" regex="{$pattern}">
      <xsl:matching-substring>
        <opera:error>
          <opera:code><xsl:value-of select="regex-group(1)"/></opera:code>
          <opera:message><xsl:value-of select="regex-group(2)"/></opera:message>
        </opera:error>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <opera:error>
          <xsl:value-of select="current()"/>
        </opera:error>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

</xsl:stylesheet>