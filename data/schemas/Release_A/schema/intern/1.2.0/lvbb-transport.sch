<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">

  <sch:ns uri="http://localfunctions/opera/common" prefix="common"/>
  <sch:ns uri="http://localfunctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://www.overheid.nl/2017/lvbb" prefix="lvbbt"/>

	<sch:p>Versie: 1.2.0</sch:p>

  <xsl:include href="/lib/stylesheets/1.2.0/controle-identifier.xsl"/>

  <sch:pattern name="Controleer Aanwezig Datum Bekendmaking bij Aanwezig Publictaie">
    <sch:rule context="/*/lvbbt:publicatie">

      <!-- mogelijke fout -->
      <sch:let name="fout-geen-datum-bekendmaking"
               value="common:store-error('LVBB1505','[Controleer Aanwezig Datum Bekendmaking bij Aanwezig Publicatie] Geen datum bekendmaking aanwezig terwijl er wel een publicatie aanwezig is')"/>

      <sch:assert role="fout" test="count(../lvbbt:datumBekendmaking) = 1">
        <sch:value-of select="$fout-geen-datum-bekendmaking"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controle juiste opbouw AKN werk of expressie -->

  <sch:pattern name="Controleer juiste opbouw AKN">
    <sch:rule context="/*/lvbbt:identificatie">
      <sch:let name="identifier" value="./string()"/>
      <sch:let name="reeks" value="tokenize($akn,'/')"/>
      <sch:let name="is-werk" value="count($reeks) le 7"/>
      <sch:let name="meldingen"
               value="if ($is-werk) then akn-join:controle-work-identifier($identifier, 'akn', false()) else akn-join:controle-expression-identifier($identifier, 'akn', false())"/>
      <sch:assert role="fout" test="empty($meldingen)">
        <sch:value-of select="string-join($meldingen,common:get-messages-marker())"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'bill' ($typeBesluit van controle-akn-join.xsl) -->

  <sch:pattern name="Controles AKN aanvullend bill">
    <sch:rule context="/*/lvbbt:identificatie">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>

      <!-- mogelijke fout -->
      <sch:let name="fout-aanlevering"
               value="common:store-error('LVBB1502',concat('[Opdracht - Controleer Inhoud Identificatie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$typeBesluit,' of ',$typeKennisgeving))"/>

      <sch:assert role="fout" test="($type = $typeBesluit or $typeKennisgeving)">
        <sch:value-of select="$fout-aanlevering"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema> 