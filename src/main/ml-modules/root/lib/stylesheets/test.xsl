<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdmp="http://marklogic.com/xdmp"
                xmlns:util="http://marklogic.com/schema-validator/lib/stylesheets/utilities"
                extension-element-prefixes="xdmp"
                exclude-result-prefixes="#all"
                version="2.0">
  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/stylesheets/utilities" href="/lib/stylesheets/utilities.xqy"/>

  <xsl:template match="/">
    <xsl:variable name="inputString1">LVBB1501#$#@#$#[Opdracht- Controleer Inhoud Datum Bekendmaking] Datum bekendmaking 2023-07-25 moet in de toekomst liggen</xsl:variable>
    <xsl:variable name="inputString2">code1#$#@#$#msg1##@##code2#$#@#$#msg2</xsl:variable>
    <xsl:variable name="inputString3">code1#$#@#$#msg1##@##code2#$#@#$#msg2##@##code3#$#@#$#msg3</xsl:variable>
    <xsl:variable name="inputJSON1">{"code": "BHKV1005", "id": "/join/id/stop/work_004", "melding": "Het geleverde besluit heeft als soortWork '/join/id/stop/work_004' , Dit moet zijn: '/join/id/stop/work_003'.", "ernst": "fout"},</xsl:variable>
    <xsl:variable name="inputJSON2">{"code": "code1", "id": "/a/b/c/d", "melding": "msg '1'", "ernst": "fout"},{"code": "code2", "id": "/a/b/c/e", "melding": "msg '2'", "ernst": "waarschuwing"},</xsl:variable>
    <xsl:variable name="inputString" select="$inputJSON2"/>

    <xsl:variable name="json-pattern">(\{.*\}).?</xsl:variable>
    <xsl:variable name="message-pattern">(.*?)##@##</xsl:variable>
    <xsl:variable name="code-pattern">(.*?)#\$#@#\$#(.*)</xsl:variable>
    <result>
      <xsl:choose>
        <xsl:when test="matches($inputString, $message-pattern)">
          <xsl:analyze-string select="$inputString" regex="{$message-pattern}">
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
        <xsl:when test="matches($inputString, $code-pattern)">
          <xsl:call-template name="filterString">
            <xsl:with-param name="inputString" select="$inputString"/>
            <xsl:with-param name="pattern" select="$code-pattern"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="matches($inputString, $json-pattern)">
          <xsl:variable name="result" select="util:convert-json-string-to-xml($inputString)"/>
          <xsl:copy-of select="$result"/>
        </xsl:when>
        <xsl:otherwise>
          <oeps>
            <xsl:value-of select="$inputString"/>
          </oeps>
        </xsl:otherwise>
      </xsl:choose>
    </result>
  </xsl:template>

  <xsl:template name="filterString">
    <xsl:param name="inputString"/>
    <xsl:param name="pattern"/>

    <xsl:analyze-string select="$inputString" regex="{$pattern}">
      <xsl:matching-substring>
        <error>
          <code><xsl:value-of select="regex-group(1)"/></code>
          <message><xsl:value-of select="regex-group(2)"/></message>
        </error>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <error>
          <xsl:value-of select="current()"/>
        </error>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

</xsl:stylesheet>
