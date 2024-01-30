<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- een tijdelijke controle die het toelaat dat er maar 1 doel aanwezig mag zijn in een manifest-bhkv -->
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://www.geostandaarden.nl/bestanden-ow/manifest-ow" prefix="mow"/>
  <xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
  <!-- Controle juiste opbouw AKN werk-->
  <sch:pattern name="Controleer juiste opbouw AKN">
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:WorkIDRegeling">
      <sch:let name="akn" value="."/>
      <sch:let name="reeks" value="tokenize($akn,'/')"/>
      <sch:let name="is-werk" value="count($reeks) le 7"/>
      <sch:let name="meldingen" value="if ($is-werk) then akn-join:controle-akn-werk($akn,'werk') else ()"/>
      <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- Controles AKN aanvullend: controle op 'act' -->
  <sch:pattern name="Controles AKN aanvullend act">
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:WorkIDRegeling">
      <sch:let name="invoer" value="./string()"/>
      <sch:let name="reeks" value="tokenize($invoer,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-geen-act" value="common:store-error('LVBB4005',concat('[Manifest-bhkv - Controleer WorkIDRegeling] Waarde van type ',$type,' binnen ',$invoer,' is niet gelijk aan ',$type-regeling))"/>
      <sch:assert test="$type = $type-regeling"><sch:value-of select="$fout-geen-act"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- Controle : er mogen uitsluitend objecttypes geometrie voorkomen -->
  <sch:pattern name="Controle Bestand">
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:Bestand/mow:objecttype">
      <sch:let name="objecttype" value="./string()"/>
      <sch:let name="naam" value="../mow:naam/string()"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-geometrie" value="common:store-error('LVBB1035',concat('[Manifest-bhkv - Controleer bestand] Alleen Objecttype Geometrie is toegestaan; komt NIET voor bij bestand met naam ',$naam))"/>
      <sch:assert test="$objecttype = 'Geometrie'"><sch:value-of select="$fout-geometrie"/></sch:assert>
    </sch:rule>
    <!-- Controle : er mogen uitsluitend bestandsnamen eindigen op .gml -->
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:Bestand/mow:naam">
      <sch:let name="naam" value="./string()"/>
      <sch:let name="reeks" value="tokenize($naam,'\.')"/>
      <sch:let name="extensie" value="$reeks[last()]"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-naam" value="common:store-error('LVBB1036',concat('[Manifest-bhkv - Controleer bestand] Bestand met naam ',$naam,' eindigt NIET op .gml en dat is niet toegestaan'))"/>
      <sch:assert test="$extensie = 'gml'"><sch:value-of select="$fout-naam"/></sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>