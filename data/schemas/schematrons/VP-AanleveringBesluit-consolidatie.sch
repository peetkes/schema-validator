<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xdmp="http://marklogic.com/xdmp">
  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron/schematron-mutaties" prefix="schmut"/>
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns uri="localFunctions" prefix="fct"/>

  <xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron/schematron-mutaties" href="/projects/opera/repos/opera/contexts/cds/lib/schematron/schematron-mutaties.xqy"/>

  <!-- Controleer of elk WijzigLid / WijzigArtikel een verwijzing heeft naar een WijzigBijlage en omgekeerd -->
  <!-- NB: Er bestaat een maximum lengte van wat in de context of test kan, vandaar opsplitsingen -->
  <sch:pattern name="Controleer WijzigArtikel / WijzigLid / WijzigBijlage">
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:WijzigBijlage">
      <sch:let name="eId" value="@eId/string()"/>
      <sch:let name="test1" value="($eId = /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:Lichaam//tekst:WijzigArtikel/tekst:Wat/tekst:IntRef/@ref/string())                                or ($eId = /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:Lichaam//tekst:WijzigArtikel/tekst:WijzigLid/tekst:Wat/tekst:IntRef/@ref/string())                      or ($eId = /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/tekst:Wat/tekst:IntRef/@ref/string())"/>
      <sch:let name="test2" value="($eId = /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/tekst:WijzigLid/tekst:Wat/tekst:IntRef/@ref/string())                      or ($eId = /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/tekst:Wat/tekst:IntRef/@ref/string())                      or ($eId = /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/tekst:WijzigLid/tekst:Wat/tekst:IntRef/@ref/string())"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-wijzigbijlage-zonder-relatie" value="common:store-error('LVBB4002',concat('[AanleveringBesluit - Controleer WijzigBijlage] WijzigBijlage met eId ',$eId,' heeft geen relatie tot een WijzigArtikel of WijzigLid'))"/>
      <sch:assert test="($test1 = true()) or ($test2 = true())"><sch:value-of select="$fout-wijzigbijlage-zonder-relatie"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op relatie soort-regeling / soort-werk -->
  <sch:pattern name="Controles AKN aanvullend soort-regeling / soort-werk">
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie">
      <sch:let name="expressie" value="./data:FRBRExpression/string()"/>
      <sch:let name="soort-werk" value="./data:soortWork/string()"/>
      <sch:let name="node1" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen and @wordt=$expressie]"/>
      <sch:let name="node2" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen and @wordt=$expressie]"/>
      <sch:let name="node3" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen and @wordt=$expressie]"/>
      <sch:let name="node-name" value="if (not(empty($node1))) then local-name($node1) else if (not(empty($node2))) then local-name($node2) else local-name($node3)"/>
      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-relatie-soort-werk" value="common:store-error('LVBB4044',concat('soortWork ',$soort-werk,' van element ',$node-name,' is ongelijk aan hetgeen wat verwacht wordt (bij een regelingTijdelijkDeel hoort &quot;soortwork_021&quot;, bij de overige soort regelingen hoort &quot;soortwork_019&quot;).'))"/>
      <sch:assert test="($node-name = ('RegelingTijdelijkdeel','RegelingMutatie') and $soort-werk = '/join/id/stop/work_021') or (not($node-name = 'RegelingTijdelijkdeel') and $soort-werk = '/join/id/stop/work_019')"><sch:value-of select="$fout-relatie-soort-werk"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'act' binnen regelingversie -->
  <sch:pattern name="Controles AKN aanvullend 'act'">
    <!-- onderstaande test wordt opgedeeld in 3 stukken omdat de context een beperkte lengte aan kan voor het juist verwerken -->
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:Intrekkingen/data:Intrekking/data:instrument[starts-with(.,$akn-start)] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:instrumentVersie |                       /lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:RegelingMetadata/data:opvolging/data:opvolgerVan |            /lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRWork |            /lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRExpression">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>
      <!-- mogelijke fout -->
      <sch:let name="fout-geen-regeling" value="common:store-error('LVBB1517',concat('[AanleveringBesluit - Controleer Inhoud Identificatie Regelingversie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-regeling))"/>
      <sch:assert test="$type = $type-regeling"><sch:value-of select="$fout-geen-regeling"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/@wordt |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/@was |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingCompact/@wordt |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingCompact/@was">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>
      <!-- mogelijke fout -->
      <sch:let name="fout-geen-regeling" value="common:store-error('LVBB1517',concat('[AanleveringBesluit - Controleer Inhoud Identificatie Regelingversie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-regeling))"/>
      <sch:assert test="$type = $type-regeling"><sch:value-of select="$fout-geen-regeling"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingVrijetekst/@wordt |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingVrijetekst/@was |         /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingVrijetekst/@wordt |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingTijdelijkdeel/@wordt |         /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingVrijetekst/@wordt |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingTijdelijkdeel/@was">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>
      <!-- mogelijke fout -->
      <sch:let name="fout-geen-regeling" value="common:store-error('LVBB1517',concat('[AanleveringBesluit - Controleer Inhoud Identificatie Regelingversie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-regeling))"/>
      <sch:assert test="$type = $type-regeling"><sch:value-of select="$fout-geen-regeling"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Ga na of elke AKN wordt in mutatie-element ook voorkomt als instrumentVersie in BeoogdeRegeling / BeoogdInformatieobject en omgekeerd -->
  <!-- NB: Er bestaat een maximum lengte van wat in de context kan, vandaar een opsplitsing -->
  <sch:pattern name="Controles AKN aanvullend voorkomens wordt - BeoogdeRegeling">
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |                        /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]">
      <sch:let name="frbr-expressie" value="@wordt/string()"/>
      <sch:let name="instrument-versies" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:instrumentVersie/string(),',')"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4032',concat('[AanleveringBesluit - Controles Besluit AKN aanvullend expressie] Expressie ',$frbr-expressie,' komt niet voor als instrumentVersie binnen BeoogdeRegeling'))"/>
      <sch:assert test="contains($instrument-versies,$frbr-expressie)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek">
      <sch:let name="frbr-expressie" value="@wordt/string()"/>
      <sch:let name="instrument-versies" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:instrumentVersie/string(),',')"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4032',concat('[AanleveringBesluit - Controles Besluit AKN aanvullend expressie] Expressie ',$frbr-expressie,' komt niet voor als instrumentVersie binnen BeoogdeRegeling'))"/>
      <sch:assert test="contains($instrument-versies,$frbr-expressie)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:instrumentVersie">
      <sch:let name="wordt-versies-1" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-2" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-3" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-4" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-5" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-6" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/@wordt/string()"/>
      <sch:let name="invoer" value="./string()"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4032',concat('[AanleveringBesluit - Controles BeoogdeRegeling AKN aanvullend] Expressie ',$invoer,' komt niet voor als @wordt binnen een regeling'))"/>
      <sch:assert test="contains($wordt-versies-1,.) or contains($wordt-versies-2,.) or contains($wordt-versies-3,.) or contains($wordt-versies-4,.) or contains($wordt-versies-5,.) or contains($wordt-versies-6,.)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdInformatieobject/data:instrumentVersie">
      <sch:let name="io-refs" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:BesluitMetadata/data:informatieobjectRefs/data:informatieobjectRef/string(),',')"/>
      <sch:let name="invoer" value="./string()"/>
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4032',concat('[AanleveringBesluit - Controles BeoogdeRegeling JOIN aanvullend] Expressie ',$invoer,' komt niet voor als informatieobjectRef binnen BesluitMetadata'))"/>
      <sch:assert test="contains($io-refs,.)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Ga na of elke AKN wordt in mutatie-element ook voorkomt als FRBRExpression in ExpressionIdentificatie van RegelingVersieInformatie en omgekeerd -->
  <!-- NB: Er bestaat een maximum lengte van wat in de context kan, vandaar een opsplitsing -->
  <sch:pattern name="Controles AKN aanvullend voorkomens wordt - RegelingVersieInformatie">
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |                        /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]">
      <sch:let name="frbr-expressie" value="@wordt/string()"/>
      <sch:let name="regeling-versies-akns" value="string-join(/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRExpression/string(),',')"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4033',concat('[AanleveringBesluit - Controles Besluit AKN aanvullend expressie] Expressie ',$frbr-expressie,' komt niet voor als FRBRExpression binnen ExpressionIdentificatie van RegelingVersieInformatie'))"/>
      <sch:assert test="contains($regeling-versies-akns,$frbr-expressie)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen] |                       /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek">
      <sch:let name="frbr-expressie" value="@wordt/string()"/>
      <sch:let name="regeling-versies-akns" value="string-join(/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRExpression/string(),',')"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4033',concat('[AanleveringBesluit - Controles Besluit AKN aanvullend expressie] Expressie ',$frbr-expressie,' komt niet voor als FRBRExpression binnen ExpressionIdentificatie van RegelingVersieInformatie'))"/>
      <sch:assert test="contains($regeling-versies-akns,$frbr-expressie)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
    <sch:let name="intrekkingen" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:Intrekkingen/data:Intrekking/data:instrument[starts-with(.,$akn-start)]/string()"/>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRExpression[not(../data:FRBRWork/string() = $intrekkingen)]">
      <sch:let name="wordt-versies-1" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-2" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-3" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-4" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-5" value="string-join(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]/@wordt/string(),',')"/>
      <sch:let name="wordt-versies-6" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/@wordt/string()"/>
      <sch:let name="invoer" value="./string()"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-komt-niet-voor" value="common:store-error('LVBB4033',concat('[AanleveringBesluit - Controles RegelingVersieInformatie AKN aanvullend] Expressie ',$invoer,' komt niet voor als @wordt binnen een regeling'))"/>
      <sch:assert test="contains($wordt-versies-1,.) or contains($wordt-versies-2,.) or contains($wordt-versies-3,.) or contains($wordt-versies-4,.) or contains($wordt-versies-5,.) or contains($wordt-versies-6,.)"><sch:value-of select="$fout-komt-niet-voor"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Als er geen was-versie is dan moet er voor de wordt-versie een RegelingMetadata aanwezig zijn -->
  <!-- NB: Er bestaat een maximum lengte van wat in de context kan, vandaar een opsplitsing -->
  <sch:pattern name="Controles AKN aanvullend voorkomens wordt - RegelingVersieInformatie">
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |  /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |   /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen]">
      <sch:let name="was-versie" value="./@was"/>
      <sch:let name="wordt-versie" value="./@wordt/string()"/>
      <sch:let name="regeling-metadata" value="(/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie[data:ExpressionIdentificatie/data:FRBRExpression/string()=$wordt-versie]/data:RegelingMetadata)[1]"/>
      <sch:let name="regeling" value="(/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie[data:FRBRExpression/string()=$wordt-versie]/data:FRBRWork/string())[1]"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-geen-regeling-metadata" value="common:store-error('LVBB4040',concat('[AanleveringBesluit - RegelingMetadata nieuwe Regeling] Geen RegelingMetadata aanwezig bij eerste regelingversie ', $wordt-versie, ' binnen nieuwe regeling ',$regeling))"/>
      <sch:assert test="not(empty($was-versie)) or not(empty($regeling-metadata))"><sch:value-of select="$fout-geen-regeling-metadata"/></sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:WijzigBijlage/node()[local-name(.)=$mutatie-elementen] |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel/node()[local-name(.)=$mutatie-elementen] |           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek">
      <sch:let name="was-versie" value="./@was"/>
      <sch:let name="wordt-versie" value="./@wordt/string()"/>
      <sch:let name="regeling-metadata" value="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie[data:ExpressionIdentificatie/data:FRBRExpression/string()=$wordt-versie]/data:RegelingMetadata"/>
      <sch:let name="regeling" value="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie[data:FRBRExpression/string()=$wordt-versie]/data:FRBRWork/string()"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-geen-regeling-metadata" value="common:store-error('LVBB4040',concat('[AanleveringBesluit - RegelingMetadata nieuwe Regeling] Geen RegelingMetadata aanwezig bij eerste regelingversie ', $wordt-versie, ' binnen nieuwe regeling ',$regeling))"/>
      <sch:assert test="empty($wordt-versie) or not(empty($was-versie)) or not(empty($regeling-metadata))"><sch:value-of select="$fout-geen-regeling-metadata"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Er mag niet twee keer RegelingVersieInformatie aanwezig zijn voor dezelfde FRBRExpresssion -->
  <sch:pattern name="Controle meerdere voorkomens RegelingVersieInformatie">
    <sch:rule context="/lvbba:AanleveringBesluit">
      <sch:let name="wordt-versies" value="./lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
      <sch:let name="dubbelen" value="fct:get-dubbelen($wordt-versies)"/>
      <!-- mogelijke foutmelding -->
      <sch:let name="fout-dubbelen-aanwezig" value="common:store-error('LVBB4045',concat('[AanleveringBesluit - voorkomens RegelingVersieInformatie] Er zijn meerdere elementen met dezelfde RegelingVersieInformatie gevonden : ', string-join($dubbelen,', ')))"/>
      <sch:assert test="empty($dubbelen)"><sch:value-of select="$fout-dubbelen-aanwezig"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Als er een eerste RegelingMutatie is dan moeten de wIds binnen deze RegelingMutatie aan bepaalde voorwaardes voldoen,
       deze voorwaardes worden in een XQuery functie gecontroleerd -->
  <!-- Controles voor eventueel volgende RegelingMutatie worden opgestart vanuit VP-RegelingVersie-post.sch -->
  <sch:pattern name="Controles binnen eerste RegelingMutatie">
    <sch:rule context="//tekst:RegelingMutatie">
      <sch:let name="regeling-mutatie" as="element()" value="."/>
      <sch:let name="schemaversie" value="ancestor::lvbba:AanleveringBesluit/@schemaversie/string()"/>
      <sch:let name="meldingen" as="xs:string*" value="schmut:controleer-wids-in-regeling-mutatie($regeling-mutatie,$schemaversie)"/>
      <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <xsl:function name="fct:get-dubbelen" as="xs:string*">
    <xsl:param name="wordt-versies" as="xs:string*"/>
      <xsl:variable name="distinct-wordt-versies" select="distinct-values($wordt-versies)"/>
	  <xsl:for-each select="$distinct-wordt-versies">
	    <xsl:variable name="wordt-versie" select="."/>
		<xsl:variable name="aantal" select="count($wordt-versies[. = $wordt-versie])"/>
		<xsl:if test="$aantal gt 1">
			<xsl:value-of select="concat($wordt-versie,' komt ',$aantal, ' keer voor')"/>
		</xsl:if>
	  </xsl:for-each>
  </xsl:function>
</sch:schema>