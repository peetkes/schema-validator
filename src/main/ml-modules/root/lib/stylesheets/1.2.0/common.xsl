<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:local="http://localfunctions/opera/common"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:variable name="regeling-types" as="xs:string*"
                select="('RegelingCompact','RegelingKlassiek','RegelingVrijetekst','RegelingTijdelijkdeel')"/>
  <xsl:variable name="mutatie-elementen" as="xs:string*"
                select="($regeling-types,'RegelingMutatie')"/>
  <xsl:variable name="code-message-marker" as="xs:string" select="'#$#@#$#'"/>
  <xsl:variable name="messages-marker" as="xs:string" select="'##@##'"/>

  <xsl:variable name="foutcodes" as="element(foutcode)*">
    <foutcode lvbb-id="LVBB2008" message="%1 Waarde van eerste string %2 binnen %3 is niet gelijk aan %4"/>
    <foutcode lvbb-id="LVBB2009" message="%1 Waarde van tweede string %2 binnen %3 is niet gelijk aan een waarde binnen %4"/>
    <foutcode lvbb-id="LVBB2010" message="%1 Waarde van derde string %2 binnen %3 is niet gelijk aan een waarde binnen %4"/>
    <foutcode lvbb-id="LVBB2011" message="%1 Waarde van tweede string %2 binnen %3 is niet gelijk aan id"/>
    <foutcode lvbb-id="LVBB2012" message="%1 Waarde van derde string %2 binnen %3 is niet gelijk aan een waarde binnen %4"/>
    <foutcode lvbb-id="LVBB2013" type="1" message="%1 Waarde van %2-datum %3 binnen %4 heeft een lengte ongelijk aan 4 of 10"/>
    <foutcode lvbb-id="LVBB2013" type="2" message="%1 Waarde van %2-datum %3 binnen %4 is niet numeriek"/>
    <foutcode lvbb-id="LVBB2013" type="3" message="%1 Waarde van %2-datum %3 binnen %4 is geen juiste datum"/>
    <foutcode lvbb-id="LVBB2015" message="%1 Waarde van expressie-datum %2 binnen %3 moet hetzelfde zijn of later als datum werk %4"/>
    <foutcode lvbb-id="LVBB2016" message="%1 Waarde van taal %2 binnen van %3 is niet gelijk aan een waarde binnen %4"/>
    <foutcode lvbb-id="LVBB2017" message="%1 Waarde %2 mag geen punt bevatten'))"/>
    <foutcode lvbb-id="LVBB2019" message="%1 Expressie %2 bevat geen 7 delen vooraf gegaan door een '/' gevolgd door een deel dat vooraf gaat met '@'"/>
    <foutcode lvbb-id="LVBB2020" message="%1 Waarde van zevende string %2 binnen %3 voldoet niet aan de reguliere expressie '[a-zA-Z0-9][a-zA-Z0-9\_\-]*'"/>
    <foutcode lvbb-id="LVBB2021" message="%1 Waarde van zevende string %2 binnen %3 is langer dan 128 tekens"/>
    <foutcode lvbb-id="LVBB2022" message="%1 Waarde van publicatie %2 binnen %3 is niet gelijk aan een waarde binnen %4"/>
  </xsl:variable>

  <xsl:function name="local:get-message-with-type" as="xs:string">
    <xsl:param name="lvbb-id" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="parameters" as="xs:string*"/>
    <xsl:variable name="message" as="xs:string*" select="$foutcodes[@lvbb-id=$lvbb-id and @type=$type]/@message/string()"/>
    <xsl:value-of select="local:process-message($lvbb-id,$message,$parameters)"/>
  </xsl:function>

  <xsl:function name="local:get-message" as="xs:string">
    <xsl:param name="lvbb-id" as="xs:string"/>
    <xsl:param name="parameters" as="xs:string*"/>
    <xsl:variable name="message" as="xs:string*" select="$foutcodes[@lvbb-id=$lvbb-id]/@message/string()"/>
    <xsl:value-of select="local:process-message($lvbb-id,$message,$parameters)"/>
  </xsl:function>

  <xsl:function name="local:process-message" as="xs:string">
    <xsl:param name="lvbb-id" as="xs:string"/>
    <xsl:param name="message" as="xs:string*"/>
    <xsl:param name="parameters" as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="empty($message)">
        <xsl:value-of select="local:store-error($lvbb-id,'Geen melding gevonden')"/>
      </xsl:when>
      <xsl:when test="count($message) gt 1">
        <xsl:value-of select="local:store-error($lvbb-id,'Meer dan 1 melding gevonden')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="message-1" select="local:inject-parameter($message,'%1',$parameters[1])"/>
        <xsl:variable name="message-2" select="local:inject-parameter($message-1,'%2',$parameters[2])"/>
        <xsl:variable name="message-3" select="local:inject-parameter($message-2,'%3',$parameters[3])"/>
        <xsl:variable name="message-4" select="local:inject-parameter($message-3,'%4',$parameters[4])"/>
        <xsl:variable name="message-5" select="local:inject-parameter($message-4,'%5',$parameters[5])"/>
        <xsl:variable name="message-6" select="local:inject-parameter($message-5,'%6',$parameters[6])"/>
        <xsl:variable name="message-7" select="local:inject-parameter($message-6,'%7',$parameters[7])"/>
        <xsl:variable name="message-8" select="local:inject-parameter($message-7,'%8',$parameters[8])"/>
        <xsl:value-of select="local:store-error($lvbb-id,$message-8)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="local:inject-parameter" as="xs:string">
    <xsl:param name="message" as="xs:string"/>
    <xsl:param name="source" as="xs:string"/>
    <xsl:param name="dest" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="empty($dest)">
        <xsl:value-of select="$message"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="replace($message,$source,$dest)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="local:store-error" as="xs:string">
    <xsl:param name="code" as="xs:string"/>
    <xsl:param name="message" as="xs:string"/>
    <xsl:value-of select="concat($code,$code-message-marker,$message)"/>
  </xsl:function>

  <xsl:function name="local:get-messages-marker" as="xs:string">
    <xsl:value-of select="$messages-marker"/>
  </xsl:function>

</xsl:stylesheet>