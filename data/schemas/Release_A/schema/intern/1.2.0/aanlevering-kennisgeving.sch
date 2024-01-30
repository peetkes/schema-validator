<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">

  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfunctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://localfunctions/opera/common" prefix="common"/>

  <xsl:include href="/lib/stylesheets/1.2.0/controle-identifier.xsl"/>

  <!-- Controles AKN aanvullend: controle op 'doc' ($type-kennisgeving van controle-akn-join.xsl) -->

  <sch:pattern id="controle-akn-kennisgeving">
    <sch:title>Controles AKN kennisgeving</sch:title>
    <sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:ExpressionIdentificatie/data:FRBRWork |
		                   /lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:ExpressionIdentificatie/data:FRBRExpression">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>

      <sch:assert role="fout" test="$type = $typeKennisgeving">
        <sch:value-of select="common:store-error('LVBB4707',concat('[AanleveringKennisgeving - Controleer Inhoud Identificatie] Waarde van type ', $type, ' binnen ', $identificatie,' is niet gelijk aan ', $typeKennisgeving))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'bill' bij mededelingOver ($type-bill van controle-identifier.xsl) -->

  <sch:pattern id="controle-akn-bill">
    <sch:title>Controles AKN aanvullend bill</sch:title>
    <sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:mededelingOver">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>

      <sch:assert role="fout" test="$type = $typeBesluit">
        <sch:value-of select="common:store-error('LVBB4708',concat('[AanleveringKennisgeving - Controleer Inhoud Identificatie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$typeBesluit))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Deze regels zijn opgenomen om de vervang en verwijder stappen in de proceduremutatie te vlaggen voor validatie, deze mogen NIET voorkomen in een kennisgeving -->
  <sch:pattern id="bevat-stappen">
    <sch:title>Controleer of er binnen Procedureverloopmutatie binnen AanleveringKennisgeving ook stappen voorkomen</sch:title>
    <sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:Procedureverloopmutatie">
      <sch:let name="voegtoe" value="./data:voegStappenToe"/>
      <sch:let name="vervang" value="./data:vervangStappen"/>
      <sch:let name="verwijder" value="./data:verwijderStappen"/>

      <sch:report role="fout" test="empty(($voegtoe, $vervang, $verwijder))">
        <sch:value-of select="common:store-error('LVBB4762', concat('[AanleveringKennisgeving - Controleer Procedureverloopmutatie] Geen voegStappenToe, verwijderStappen of vervangStappen aanwezig binnen Procedureverloopmutatie'))"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>

  <!-- soort kennisgeving 'KennisgevingUitspraakRechter' vooralsnog niet toelaten, het schema laat dit wel toe (user story 169953) -->
  <sch:pattern id="voorlopige-controle-soort-kennisgeving">
    <sch:title>Tijdelijke controle soort kennisgeving ongelijk aan KennisgevingUitspraakRechter of KennisgevingVoorgenomenBesluit</sch:title>
    <sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:soortKennisgeving">
      <sch:let name="soortKennisgeving" value="./string()"/>

      <sch:assert role="fout" test="$soortKennisgeving ne 'KennisgevingUitspraakRechter')">
        <sch:value-of select="common:store-error('LVBB4738',concat('SoortKennisgeving ', $soortKennisgeving, ' in kennisgeving mag niet gebruikt worden'))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- bij een KennisgevingVoorgenomenBesluit mag er geen Procedureverloopmutatie of mededelingOver zijn -->
  <sch:pattern id="voorgenomen-besluit-checks">
    <sch:title>Controleer of er bij een KennisgevingVoorgenomenBesluit geen Procedureveloopmutatie voorkomt</sch:title>
    <sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie[data:KennisgevingMetadata/data:soortKennisgeving = $soortKennisgevingVoorgenomenBesluit]">
      <sch:let name="verloop" value="./data:Procedureverloopmutatie"/>
      <sch:let name="mededeling-over" value="./data:mededelingOver"/>

      <sch:report test="exists($verloop)">
        <sch:value-of select="common:store-error('LVBB4763', concat('[AanleveringKennisgeving - Controleer Procedureverloopmutatie] Bij een KennisgevingVoorgenomenBesluit is een procedureverloopmutatie niet toegestaan'))"/>
      </sch:report>
      <sch:report role="fout" test="exists($mededeling-over)">
        <sch:value-of select="common:store-error('LVBB4740', concat('[AanleveringKennisgeving - Controleer mededelingOver] Bij een KennisgevingVoorgenomenBesluit is een mededelingOver niet toegestaan')"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>

</sch:schema>