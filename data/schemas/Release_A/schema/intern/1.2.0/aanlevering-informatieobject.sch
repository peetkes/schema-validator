<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xdmp="http://marklogic.com/xdmp"
            queryBinding="xslt2">

  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <!--sch:ns uri="http://marklogic.com/schema-validator/lib/informatie-objecten" prefix="io"/-->
  <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" prefix="schint"/>
  <sch:ns uri="http://localfunctions/opera/common" prefix="common"/>
  <sch:ns uri="http://localfunctions/opera/akn-join" prefix="akn-join"/>

  <sch:p>Versie 1.2.0</sch:p>

  <!--xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/informatie-objecten"
                      href="/projects/opera/repos/opera/contexts/cds/lib/informatie-objecten.xqy"/-->
  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron-functions/intern"
                      href="/lib/schematron-functions/intern.xqy"/>

  <xsl:include href="/lib/stylesheets/1.2.0/controle-identifier.xsl"/>

  <!-- Controles JOIN aanvullend: controle op 'pubdata' of 'regdata' -->

  <sch:pattern name="Controles JOIN aanvullend collectie">
    <sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRWork">
      <sch:let name="identifier" value="./string()"/>
      <sch:let name="seq" value="tokenize($identifier,'/')"/>
      <sch:let name="documentType" value="$seq[4]"/>

      <sch:assert role="fout" test="$documentType = $documentTypesJoin">
        <sch:value-of select="common:store-error('LVBB3502',
          concat('[AanleveringInformatieObject - Controles JOIN aanvullend] Waarde van documentType ', $documentType, ' binnen ',
          $identifier, ' is niet gelijk aan waarde binnen ', string-join($documentTypesJoin, ',')))"/>
      </sch:assert>
    </sch:rule>
    <sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRExpression">
      <sch:let name="identifier" value="./string()"/>
      <sch:let name="seq" value="tokenize($identifier,'/')"/>
      <sch:let name="documentType" value="$seq[4]"/>

      <sch:assert role="fout" test="$documentType = $documentTypesJoin">
        <sch:value-of select="common:store-error('LVBB3502',
          concat('[AanleveringInformatieObject - Controles JOIN aanvullend] Waarde van documentType ', $documentType, ' binnen ',
          $identifier, ' is niet gelijk aan waarde binnen ', string-join($documentTypesJoin,',')))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Controles AKN aanvullend: controle op 'act' binnen regelingversie -->

  <sch:pattern name="Controles AKN aanvullend 'act'">
    <sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:InformatieObjectVersieMetadata/data:heeftGeboorteregeling">
      <sch:let name="identifier" value="./string()"/>
      <sch:let name="seq" value="tokenize($identifier,'/')"/>
      <sch:let name="documentType" value="$seq[4]"/>

      <sch:assert role="fout" test="$documentType = $typeRegeling">
        <sch:value-of select="common:store-error('LVBB1517',
          concat('[AanleveringInformatieObject - Controleer Inhoud Identificatie Regelingversie] Waarde van documentType ',
          $documentType, ' binnen ', $identifier, ' is niet gelijk aan ', $typeRegeling))"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Als er InformatieObjectMetadata is meegegeven dan mag deze op bepaalde punten niet afwijken van eerder aangeleverde InformatieObjectMetadata -->

  <!--sch:pattern name="Controle aanpassingen in InformatieObjectMetadata">
    <sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:InformatieObjectMetadata">
      <sch:let name="identification" value="../data:ExpressionIdentificatie"/>
      <sch:let name="work" value="$identification/data:FRBRWork"/>
      <sch:let name="expression" value="$identification/data:FRBRExpression"/>
      <sch:let name="doc-info"
               value="schint:get-doc-info-for-id(node-name($identification), fn:string($expression), node-name($work), node-name($expression))"/>
      <sch:let name="join-id-werk" value="$work/string()"/>
      <sch:let name="eindverantwoordelijke" value="./data:eindverantwoordelijke/string()"/>
      <sch:let name="formaat-informatieobject" value="./data:formaatInformatieobject/string()"/>
      <sch:let name="maker" value="./data:maker/string()"/>
      <sch:let name="officiele-titel" value="./data:officieleTitel/string()"/>
      <sch:let name="opvolging" value="string-join(./data:opvolging/data:opvolgerVan/string(),',')"/>
      <sch:let name="publicatieinstructie" value="./data:publicatieinstructie/string()"/>
      <sch:let name="meldingen"
               value="io:check-metadata-ok($join-id-werk, $doc-info, $eindverantwoordelijke, $formaat-informatieobject, $maker, $officiele-titel, $opvolging,$publicatieinstructie)"/>
      <sch:assert test="empty($meldingen)">
        <sch:value-of select="string-join($meldingen, common:get-messages-marker())"/>
      </sch:assert>
    </sch:rule>
  </sch:pattern-->

</sch:schema>