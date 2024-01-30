<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">

  <sch:ns uri="http://localfunctions/opera/common" prefix="common"/>
  <sch:ns uri="http://localfunctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://www.geostandaarden.nl/bestanden-ow/manifest-ow" prefix="mow"/>

  <sch:p>Versie: 1.2.0</sch:p>
  <xsl:include href="/lib/stylesheets/1.2.0/controle-identifier.xsl"/>

  <!-- Controle juiste opbouw AKN werk-->

  <sch:pattern name="Controleer juiste opbouw AKN">
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:WorkIDRegeling">
      <sch:let name="identifier" value="."/>
      <sch:let name="reeks" value="tokenize($identifier, '/')"/>
      <sch:let name="documentType" value="$reeks[4]"/>
      <sch:let name="is-werk" value="count($reeks) le 7"/>
      <sch:let name="meldingen" value="if ($is-werk) then akn-join:controle-work-identifier($identifier, 'akn', false()) else ()"/>

      <sch:assert role="fout" test="empty($meldingen)">
        <sch:value-of select="string-join($meldingen, common:get-messages-marker())"/>
      </sch:assert>
      <sch:assert role="fout" test="$documentType eq $typeRegeling">
        <sch:value-of select="common:store-error('LVBB4005',concat('[Manifest-OW - Controleer WorkIDRegeling] Waarde van type ',
          $documentType,' binnen ', $identifier,' is niet gelijk aan ', $typeRegeling))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles juiste opbouw JOIN werk -->

  <sch:pattern name="Controles JOIN aanvullend documentTypes for join-id">
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:DoelID">
      <sch:let name="identifier" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identifier, '/')"/>
      <sch:let name="documentType" value="$reeks[4]"/>

      <sch:assert role="fout" test="$documentType = $documentTypesJoin">
        <sch:value-of select="common:store-error('LVBB4005',concat('[Manifest-OW - Controleer DoelID] Waarde van type ',
          $documentType,' binnen ', $identifier,' is niet gelijk aan ', string-join($documentTypesJoin,',')))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controle : er mag geen objecttype geometrie voorkomen -->
  <!-- Controle : er mag geen bestandsnaam eindigen op .gml -->

  <sch:pattern name="Controle Bestand">
    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:Bestand/mow:objecttype">
      <sch:let name="objectType" value="./string()"/>
      <sch:let name="naam" value="../mow:naam/string()"/>

      <sch:assert role="fout" test="not($objectType = 'Geometrie')">
        <sch:value-of select="common:store-error('LVBB1025',
          concat('[Manifest-OW - Controleer bestand] Objecttype Geometrie is niet toegestaan; komt voor bij bestand met naam ',$naam))"/>
      </sch:assert>
    </sch:rule>

    <sch:rule context="/mow:Aanleveringen/mow:Aanlevering/mow:Bestand/mow:naam">
      <sch:let name="naam" value="./string()"/>
      <sch:let name="reeks" value="tokenize($naam,'\.')"/>
      <sch:let name="extensie" value="$reeks[last()]"/>

      <sch:assert role="fout" test="not($extensie = 'gml')">
        <sch:value-of select="common:store-error('LVBB1026',
          concat('[Manifest-OW - Controleer bestand] Bestand met naam ',$naam,' eindigt op .gml en dat is niet toegestaan'))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema> 