<?xml version="1.0" encoding="UTF-8"?>
<!-- aangepaste versie van schematron *met* validatie-op-werkdag -->
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xdmp="http://marklogic.com/xdmp">
  <sch:ns uri="http://localfunctions/opera/common" prefix="common"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/utilities/datum-utilities" prefix="datum"/>
  <sch:p>Versie 1.2.0</sch:p>

  <xsl:include href="/lib/stylesheets/1.2.0/common.xsl"/>

  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/utilities/datum-utilities" href="/lib/utilities/datum-utilities.xqy"/>
  <!-- Controle op inhoud -->
  <sch:pattern name="Controleer Aanwezig IdBevoegdGezag en IdAanleveraar">
    <sch:rule context="/*">
      <sch:let name="fout-geen-idBevoegdGezag" value="common:store-error('LVBB1510','[Controleer Aanwezig IdBevoegdGezag] Geen idBevoegdGezag aanwezig')"/>
      <sch:let name="fout-geen-idAanleveraar" value="common:store-error('LVBB1511','[Controleer Aanwezig IdAanleveraar] Geen idAanleveraar aanwezig')"/>
      <sch:assert role="fout" test="count(*:idBevoegdGezag) = 1"><sch:value-of select="$fout-geen-idBevoegdGezag"/></sch:assert>
      <sch:assert role="fout" test="count(*:idAanleveraar) = 1"><sch:value-of select="$fout-geen-idAanleveraar"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern name="Controleer Inhoud Datum Bekendmaking">
    <sch:rule context="/*/*:datumBekendmaking">
      <sch:let name="huidige-datum" value="current-date()"/>
      <sch:let name="datum-bekendmaking" value="./string()"/>
      <sch:let name="jaar" value="substring-before($datum-bekendmaking,'-')"/>
      <sch:let name="maand" value="substring-before(substring-after($datum-bekendmaking,'-'),'-')"/>
      <sch:let name="dag" value="substring-after(substring-after($datum-bekendmaking,'-'),'-')"/>
      <!-- mogelijke fouten -->
      <sch:let name="fout-onjuist-formaat" value="common:store-error('LVBB1501',concat('[Opdracht- Controleer Inhoud Datum Bekendmaking] Datum bekendmaking ',$datum-bekendmaking,' heeft niet het formaat JJJJ-MM-DD'))"/>
      <sch:let name="fout-onjuiste-datum" value="common:store-error('LVBB1501',concat('[Opdracht- Controleer Inhoud Datum Bekendmaking] Datum bekendmaking ',$datum-bekendmaking,' is geen juiste datum'))"/>
      <sch:let name="fout-niet-in-toekomst" value="common:store-error('LVBB1501',concat('[Opdracht- Controleer Inhoud Datum Bekendmaking] Datum bekendmaking ',$datum-bekendmaking,' moet in de toekomst liggen'))"/>
      <sch:let name="fout-geen-werkdag" value="common:store-error('LVBB1519',concat('[Opdracht- Controleer Inhoud Datum Bekendmaking] Datum bekendmaking ',$datum-bekendmaking,' moet een werkdag zijn'))"/>
      <sch:assert role="fout" test="string-length($datum-bekendmaking) = 10 and string-length($jaar) = 4 and string-length($maand) = 2 and string-length($dag) = 2"><sch:value-of select="$fout-onjuist-formaat"/></sch:assert>
      <sch:assert role="fout" test="not(string-length($datum-bekendmaking) = 10) or not(string-length($jaar) = 4) or not(string-length($maand) = 2) or not(string-length($dag) = 2) or empty($datum-bekendmaking) or ($datum-bekendmaking castable as xs:date)"><sch:value-of select="$fout-onjuiste-datum"/></sch:assert>
      <sch:assert role="fout" test="not(string-length($datum-bekendmaking) = 10) or not(string-length($jaar) = 4) or not(string-length($maand) = 2) or not(string-length($dag) = 2) or empty($datum-bekendmaking) or (not($datum-bekendmaking castable as xs:date)) or (xs:date($datum-bekendmaking) gt $huidige-datum)"><sch:value-of select="$fout-niet-in-toekomst"/></sch:assert>
      <sch:assert role="fout" test="not(empty($datum-bekendmaking)) and $datum-bekendmaking castable as xs:date and datum:is-werkdag(xs:date($datum-bekendmaking))"><sch:value-of select="$fout-geen-werkdag"/></sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>