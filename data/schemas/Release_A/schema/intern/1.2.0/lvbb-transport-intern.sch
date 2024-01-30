<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">

  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://www.overheid.nl/2020/lvbb-intern" prefix="lvbb-int"/>

	<sch:p>Versie 1.2.0</sch:p>

  <xsl:include href="/lib/stylesheets/1.2.0/controle-identifier.xsl"/>

  <!-- Controle juiste opbouw AKN werk of expressie -->

  <sch:pattern name="Controleer juiste opbouw AKN">
    <sch:rule context="/*/lvbb-int:vastgesteldDoor">
      <sch:let name="identifier" value="./string()"/>
      <sch:let name="reeks" value="tokenize($akn,'/')"/>
      <sch:let name="is-werk" value="count($reeks) le 7"/>
      <sch:let name="meldingen"
               value="if ($is-werk) then akn-join:controle-work-identifier($identifier,'akn', false()) else akn-join:controle-expression-identifier($identifier, 'akn', false())"/>
      <sch:assert role="fout" test="empty($meldingen)">
        <sch:value-of select="string-join($meldingen,common:get-messages-marker())"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'bill' -->

  <sch:pattern name="Controles AKN aanvullend besluit">
    <sch:rule context="/*/lvbb-int:vastgesteldDoor">
      <sch:let name="vastgesteld-door" value="./string()"/>
      <sch:let name="reeks" value="tokenize($vastgesteld-door,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>

      <!-- mogelijke fout -->
      <sch:let name="fout-geen-besluit"
               value="common:store-error('LVBB1513',concat('[Opdracht- Controleer Inhoud vastgesteldDoor] Waarde van type ',$type,' binnen ',$vastgesteld-door,' is niet gelijk aan ',$typeBbesluit))"/>

      <sch:assert role="fout" test="$type = $typeBesluit">
        <sch:value-of select="$fout-geen-besluit"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controle op de naam van consolidatie -->

  <sch:pattern name="Controles naam consolidatie">
    <sch:rule context="/*/lvbb-int:consolidatie">
      <sch:let name="naam-consolidatie" value="./string()"/>

      <!-- mogelijke fout -->
      <sch:let name="fout-naam-consolidatie"
               value="common:store-error('LVBB1516',concat('[Opdracht- Controleer naam consolidatie] Naam van consolidatie bestand is ',$naam-consolidatie,' en daarmee niet gelijk aan consolidaties.xml'))"/>

      <sch:assert role="fout" test="$naam-consolidatie = 'consolidaties.xml'">
        <sch:value-of select="$fout-naam-consolidatie"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema> 