<sch:schema queryBinding="xslt2"
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xdmp="http://marklogic.com/xdmp">

  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/uitlevering/" prefix="lvbbu"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/consolidatie/" prefix="consolidatie"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" prefix="schint"/>

  <xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>

  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" href="/projects/opera/repos/opera/contexts/cds/lib/schematron/schematron-intern.xqy"/>

  <sch:let name="soort-opdracht"
    value="schint:get-soort-opdracht(
      node-name(/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie),
      node-name(/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork),
      /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork/string())"/>
  <sch:let name="is-doorleveren" value="($soort-opdracht = 'doorleverenRegelingVersie') or ($soort-opdracht = 'valideerDoorleverenRegelingVersie')"/>
  <sch:let name="uitsluitend-intrekking"
    value="empty(/lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:AnnotatieBijToestand) and
           not(empty(/lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:IntrekkingRegeling))"/>
  <sch:let name="is-doorleveren-uitsluitend-intrekking" value="$is-doorleveren and $uitsluitend-intrekking"/>

  <!-- bepaalde voorkomens van AKN moeten een bevoegd gezag hebben -->
  <sch:pattern name="Controleer AKN aanvullend bevoegd gezag">
    <sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork |           /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:BekendeToestand/consolidatie:FRBRExpression">
      <sch:let name="akn" value="./string()"/>
      <sch:let name="reeks" value="tokenize($akn,'/')"/>
      <sch:let name="bevoegd-gezag" value="$reeks[5]"/>
      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-bevoegd-gezag" value="common:store-error('LVBB7709',concat('[Controleer AKN aanvullend bevoegd gezag] akn ',$akn,' heeft een bevoegd gezag ',$bevoegd-gezag,' en is dat niet gelijk aan een waarde binnen ',string-join($bevoegd-gezagen,', ')))"/>
      <sch:assert test="$bevoegd-gezag = $bevoegd-gezagen"><sch:value-of select="$fout-bevoegd-gezag"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- Precies 1 voorkomen van RegelingVersie -->
  <sch:pattern name="Controleer voorkomen RegelingVersie / AnnotatieBijToestand">
    <sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie[not($is-doorleveren-uitsluitend-intrekking)]">
      <sch:let name="count-regeling-versie" value="count(./lvbbu:RegelingVersie)"/>
      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-regeling-versie" value="common:store-error('LVBB7705','[Controleer voorkomens RegelingVersie] Aantal voorkomens van RegelingVersie is niet gelijk aan 1')"/>
      <sch:assert test="$count-regeling-versie = 1"><sch:value-of select="$fout-regeling-versie"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- Extra controles op AKN voorkomens -->
  <!-- alle voorkomens van AKN moet als type 'act' hebben -->
  <!-- dit is verdeeld over twee testen omdat anders de string na context te groot werd -->
  <sch:pattern name="Controleer AKN aanvullend type">
    <sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork |                       /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:isConsolidatieVan/consolidatie:WorkIdentificatie/consolidatie:FRBRWork |           /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:BekendeToestand/consolidatie:FRBRExpression |           /lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:RegelingVersie/data:ExpressionIdentificatie/data:FRBRWork |           /lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:RegelingVersie/data:ExpressionIdentificatie/data:FRBRExpression">
      <sch:let name="akn" value="./string()"/>
      <sch:let name="reeks" value="tokenize($akn,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>
      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-type" value="common:store-error('LVBB7708',concat('[Controleer AKN aanvullend type] akn ',$akn,' heeft type ',$type,' dat is niet gelijk aan act'))"/>
      <sch:assert test="$type = $type-regeling"><sch:value-of select="$fout-type"/></sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>