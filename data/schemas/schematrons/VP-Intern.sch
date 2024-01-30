<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xdmp="http://marklogic.com/xdmp"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2" schemaVersion="1.0">

  <sch:title>check-intern</sch:title>

  <sch:ns uri="http://koop.overheid.nl/apps/opera/" prefix="opera"/>
  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" prefix="schint"/>
  <sch:ns uri="localFunctions" prefix="fct"/>

  <xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/common.xsl"/>

  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" href="/projects/opera/repos/opera/contexts/cds/lib/schematron/schematron-intern.xqy"/>

  <sch:phase id="all">
    <sch:active pattern="check-was-gepubliceerd"></sch:active>
    <sch:active pattern="check-vaststellend-besluit"></sch:active>
  </sch:phase>

  <sch:pattern id="check-was-gepubliceerd">
    <sch:rule context="tekst:RegelingMutatie[not(@was = //tekst:RegelingMutatie/@wordt)]">
      <sch:let name="was" value="string(@was)"/>
      <sch:let name="result" value="schint:check-besluit-was-gepubliceerd($was)"/>
      <sch:report test="$result eq 2"><sch:value-of select="common:store-error('LVBB4211',concat('Het besluit dat de was-versie ', $was,' vaststelt is nog niet gepubliceerd.'))"/></sch:report>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="check-vaststellend-besluit">
    <sch:rule context="data:Intrekking/data:instrument">
      <sch:let name="parent" value="(/*/*/data:ExpressionIdentificatie)[1]"/>
      <sch:let name="work" value="$parent/data:FRBRWork"/>
      <sch:let name="expression" value="$parent/data:FRBRExpression"/>
      <sch:let name="doc-info" value="schint:get-doc-info-for-id(node-name($parent), fn:string($expression), node-name($work), node-name($expression))"/>
      <sch:let name="instrument" value="string(.)"/>
      <sch:let name="result" value="schint:check-vaststellend-besluit-is-gepubliceerd($instrument, $doc-info)"/>
      <sch:report test="$result eq 2"><sch:value-of select="common:store-error('LVBB4212',concat('Het besluit dat de in te trekken regeling ', $instrument,' vaststelt is nog niet gepubliceerd.'))"/></sch:report>
    </sch:rule>

    <sch:rule context="data:InformatieObjectVersieMetadata/data:heeftGeboorteregeling">
      <sch:let name="parent" value="(/*/*/data:ExpressionIdentificatie)[1]"/>
      <sch:let name="work" value="$parent/data:FRBRWork"/>
      <sch:let name="expression" value="$parent/data:FRBRExpression"/>
      <sch:let name="doc-info" value="schint:get-doc-info-for-id(node-name($parent), fn:string($expression), node-name($work), node-name($expression))"/>
      <sch:let name="instrument" value="fn:string(.)"/>
      <sch:let name="result" value="schint:check-vaststellend-besluit-is-gepubliceerd($instrument, $doc-info)"/>
      <sch:report test="$result eq 2"><sch:value-of select="common:store-error('LVBB4212',concat('Het besluit dat de geboorteregeling ', $instrument,' vaststelt is nog niet gepubliceerd.'))"/></sch:report>
      <sch:report test="$result eq 4"><sch:value-of select="common:store-error('LVBB3510',concat('Geboorteregeling ', $instrument, ' in informatie-object ', $expression, ' komt niet voor als regeling'))"/></sch:report>
    </sch:rule>

    <sch:rule context="data:isTijdelijkDeelVan/data:WorkIdentificatie/data:FRBRWork">
      <sch:let name="instrument" value="fn:string(.)"/>
      <sch:let name="result" value="schint:check-vaststellend-besluit-is-gepubliceerd($instrument)"/>
      <sch:report test="$result eq 2"><sch:value-of select="common:store-error('LVBB4212',concat('Het besluit met de hoofdregeling van het tijdelijk deel is nog niet gepubliceerd.'))"/></sch:report>
    </sch:rule>
  </sch:pattern>
<sch:pattern id="check-tpods">

    <sch:let name="id-besluit" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRExpression |
                                      /lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:mededelingOver"/>
    <sch:let name="eindverantwoordelijke" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:BesluitMetadata/data:eindverantwoordelijke |
                                                 /lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:eindverantwoordelijke"/>

    <!-- variant 1 : een besluit met RegelingVersieInformatie -->

    <sch:rule context="lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie">
      <sch:let name="id-regeling" value="data:ExpressionIdentificatie/data:FRBRWork/string()"/>
      <sch:let name="id-versie" value="data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
      <sch:let name="soort-regeling" value="data:RegelingMetadata/data:soortRegeling/string()"/>
      <sch:let name="type-regeling" value="local-name(../lvbba:BesluitVersie//tekst:*[@wordt=$id-versie])"/>
      <sch:let name="foutmeldingen" value="schint:controleer-tpods($id-besluit,$eindverantwoordelijke,$type-regeling,$soort-regeling,$id-regeling)"/>
      <sch:report test="not(empty($foutmeldingen))"><sch:value-of select="string-join($foutmeldingen,common:get-messages-marker())"/></sch:report>
    </sch:rule>

    <!-- variant 2 : een besluit met regelingen, die aldaar worden ingetrokken maar daar niet worden vastgesteld -->

    <sch:rule context="data:Intrekking[starts-with(data:instrument/string(),'/akn/') and empty(ancestor::lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRWork[./string() = data:instrument/string()])]">
      <sch:let name="id-regeling" value="data:instrument/string()"/>
      <sch:let name="foutmeldingen" value="schint:controleer-tpods($id-besluit,$eindverantwoordelijke,(),(),$id-regeling)"/>
      <sch:report test="not(empty($foutmeldingen))"><sch:value-of select="string-join($foutmeldingen,common:get-messages-marker())"/></sch:report>
    </sch:rule>

    <!-- variant 3 : een kennisgeving met een relatie naar een besluit, dan een relatie leggen tussen de eindverantwoordelijke van de
         kennisgeving en de regelingen in het gerelateerde besluit volgens variant 1 of 2 hierboven  -->

    <sch:rule context="data:mededelingOver[ancestor::lvbba:AanleveringKennisgeving]">
      <sch:let name="id-kennisgeving" value="../../data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
      <sch:let name="id-regeling" value="schint:zoek-id-regeling-bij-besluit($id-besluit)"/>
      <sch:let name="foutmeldingen" value="schint:controleer-tpods($id-kennisgeving,$eindverantwoordelijke,(),(),$id-regeling)"/>
      <sch:report test="not(empty($foutmeldingen))"><sch:value-of select="string-join($foutmeldingen,common:get-messages-marker())"/></sch:report>
    </sch:rule>

  </sch:pattern>

</sch:schema>