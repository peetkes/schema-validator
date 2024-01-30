<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xdmp="http://marklogic.com/xdmp">
  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/uitlevering/" prefix="lvbbu"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron-functions/mutaties" prefix="schmut"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron-functions/intern" prefix="schint"/>
  <sch:ns uri="localFunctions" prefix="fct"/>

  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron-functions/mutaties"
                      href="/lib/schematron-functions/mutaties.xqy"/>
  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron-functions/intern"
                      href="/lib/schematron-functions/intern.xqy"/>

  <!-- Als er een RegelingMutatie is met de opgegeven regelingversie als was-versie dan moeten de wIds binnen deze RegelingMutatie
       aan bepaalde voorwaardes voldoen, deze voorwaardes worden in een XQuery functie gecontroleerd -->

  <sch:pattern name="Controles in RegelingMutatie">
    <sch:rule context="lvbbu:RegelingVersie/data:ExpressionIdentificatie">
      <sch:let name="parent" as="element()" value="."/>
      <sch:let name="work" value="$parent/data:FRBRWork"/>
      <sch:let name="expression" value="$parent/data:FRBRExpression"/>
      <sch:let name="doc-info"
               value="schint:get-doc-info-for-id(node-name($parent), fn:string($expression), node-name($work), node-name($expression))"/>
      <sch:let name="content-besluit" as="element()?" value="schmut:get-content-besluit-bij-versie($doc-info)"/>
      <sch:let name="meldingen-was" as="xs:string*"
               value="schmut:controleer-wids-in-regeling-mutatie($content-besluit//tekst:RegelingMutatie[@was=$expression],$content-besluit/@schemaversie/string())"/>

      <sch:assert role="fout" test="empty($meldingen-was)">
        <sch:value-of select="string-join($meldingen-was,common:get-messages-marker())"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>