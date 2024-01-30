<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">

  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfunctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://localfunctions/opera/common" prefix="common"/>
  <sch:ns uri="localFunctions" prefix="fct"/>
  <sch:p>Versie 1.2.0</sch:p>

  <xsl:include href="/lib/stylesheets/1.2.0/controle-identifier.xsl"/>

  <!-- Controle dat de soortRegeling met een bepaalde string moet beginnen -->

  <sch:pattern id="controleer-verwerking-soort-regeling">
    <sch:title>Controle verwerking soortRegeling</sch:title>
    <sch:rule
            context="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:RegelingMetadata[1]/data:soortRegeling">
      <sch:let name="soort" value="./string()"/>

      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-begin"
               value="common:store-error('LVBB4007',concat('[AanleveringBesluit - Controle soortRegeling] soortRegeling binnen de eerste RegelingMetadata heeft waarde ',$soort,' en begint dus niet met /join/id/stop/regelingtype_0'))"/>

      <sch:assert role="fout" test="starts-with($soort,'/join/id/stop/regelingtype_0')">
        <sch:value-of select="$fout-begin"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'bill' ($typeBesluit van controle-akn-join.xsl) -->

  <sch:pattern id="controleer-akn-bill">
    <sch:title>Controles AKN aanvullend bill</sch:title>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRWork |
		                   /lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRExpression">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>

      <!-- mogelijke fout -->
      <sch:let name="fout-geen-bill"
               value="common:store-error('LVBB1502',concat('[AanleveringBesluit - Controleer Inhoud Identificatie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$typeBesluit))"/>

      <sch:assert role="fout" test="$type = $typeBesluit">
        <sch:value-of select="$fout-geen-bill"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'act' binnen beperkt aantal plaatsen -->

  <sch:pattern id="controleer-akn-act">
    <sch:title>Controles AKN aanvullend 'act'</sch:title>
    <sch:rule
            context="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:isTijdelijkDeelVan/data:WorkIdentificatie/data:FRBRWork">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>

      <!-- mogelijke fout -->
      <sch:let name="fout-geen-regeling"
               value="common:store-error('LVBB1517',concat('[AanleveringBesluit - Controleer Inhoud Identificatie Regelingversie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$typeRegeling))"/>

      <sch:assert role="fout" test="$type = $typeRegeling">
        <sch:value-of select="$fout-geen-regeling"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="controleer-type-procedureverloop-besluit">
    <sch:title>Controles procedureverloop stappen bij verschillende types besluit</sch:title>
    <sch:let name="vaststelling" value="'/join/id/stop/procedure/stap_002'"/>
    <sch:let name="ondertekening" value="'/join/id/stop/procedure/stap_003'"/>
    <sch:let name="einde-beroepstermijn" value="'/join/id/stop/procedure/stap_016'"/>
    <sch:let name="soort-procedure" value="if (/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:BesluitMetadata/data:soortProcedure/string() eq '/join/id/stop/proceduretype_ontwerp')
			then 'ontwerp' 
			else 'definitief'"/>

    <sch:p>Binnen ontwerp besluit zijn alleen vaststelling en ondertekening toegestaan</sch:p>
    <sch:rule
            context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie[data:BesluitMetadata/data:soortProcedure/string() eq '/join/id/stop/proceduretype_ontwerp']/data:Procedureverloop/data:procedurestappen/data:Procedurestap/data:soortStap">
      <sch:let name="soort-stap" value="./string()"/>
      <sch:let name="fout-niet-in-besluit"
               value="common:store-error('LVBB4753',concat('[AanleveringBesluit - Controleer Inhoud Procedureverloop] Waarde van type ',$soort-stap,' mag niet gebruikt worden binnen ', $soort-procedure,' besluit.'))"/>
      <sch:report role="fout" test="not($soort-stap = ($vaststelling, $ondertekening))">
        <sch:value-of select="$fout-niet-in-besluit"/>
      </sch:report>
    </sch:rule>
    <sch:p>Binnen definitief besluit zijn alleen vaststelling, ondertekening en einde beroepstermijn toegestaan</sch:p>
    <sch:rule
            context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie[data:BesluitMetadata/data:soortProcedure/string() eq '/join/id/stop/proceduretype_definitief']/data:Procedureverloop/data:procedurestappen/data:Procedurestap/data:soortStap">
      <sch:let name="soort-stap" value="./string()"/>
      <sch:let name="fout-niet-in-besluit"
               value="common:store-error('LVBB4753',concat('[AanleveringBesluit - Controleer Inhoud Procedureverloop] Waarde van type ',$soort-stap,' mag niet gebruikt worden binnen ', $soort-procedure,' besluit.'))"/>
      <sch:report role="fout" test="not(./string() = ($vaststelling, $ondertekening, $einde-beroepstermijn))">
        <sch:value-of select="$fout-niet-in-besluit"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>

  <!-- Controles (voorlopig) niet-toegestane elementen -->

  <sch:pattern id="controleer-consolidatieinformatie-op-terugtrekkingen">
    <sch:title>Terugtrekkingen mogen niet worden gebruikt in release A</sch:title>
    <sch:p>Binnen release A zijn geen terugtrekkingen toegestaan</sch:p>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:Terugtrekkingen">
      <sch:let name="fout-terugtrekking-in-consolidatieinformatie"
               value="common:store-error('LVBB4500','Het is niet toegestaan terugtrekkingen in de consolidatieinformatie te gebruiken.')"/>
      <sch:assert role="fout" test="false()">
        <sch:value-of select="$fout-terugtrekking-in-consolidatieinformatie"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema> 