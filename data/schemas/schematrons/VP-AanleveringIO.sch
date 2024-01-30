  <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		    xmlns:xdmp="http://marklogic.com/xdmp"
     	queryBinding = "xslt2">			
			
   <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
   <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
   <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
   <sch:ns uri="http://marklogic.com/schema-validator/lib/informatie-objecten" prefix="io"/>
   <sch:ns uri="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" prefix="schint"/>
    <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
    <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
   
    <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/informatie-objecten" href="/projects/opera/repos/opera/contexts/cds/lib/informatie-objecten.xqy"/>
    <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/schematron/schematron-intern" href="/projects/opera/repos/opera/contexts/cds/lib/schematron/schematron-intern.xqy"/>

	<xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
   
	<!-- Controles JOIN aanvullend: controle op 'pubdata' of 'regdata' -->
	 
	<sch:pattern name="Controles JOIN aanvullend collectie">
		<sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRWork | /lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRExpression">
			<sch:let name="invoer" value="./string()"/>
			<sch:let name="reeks" value="tokenize($invoer,'/')"/>
		    <sch:let name="collectie" value="$reeks[4]"/>
			
			<!-- mogelijke foutmelding -->
            <sch:let name="fout-collectie-onjuist" value="common:store-error('LVBB3502',concat('[AanleveringInformatieObject - Controles JOIN aanvullend] Waarde van collectie ',$collectie,' binnen ',$invoer,' is niet gelijk aan waarde binnen ',string-join($collecties-informatie-object,',')))"/>
			
            <sch:assert test="$collectie = $collecties-informatie-object"><sch:value-of select="$fout-collectie-onjuist"/></sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<!-- Controles AKN aanvullend: controle op 'act' binnen regelingversie -->
	 
	<sch:pattern name="Controles AKN aanvullend 'act'">
		<sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:InformatieObjectVersieMetadata/data:heeftGeboorteregeling">
			<sch:let name="identificatie" value="./string()"/>
			<sch:let name="reeks" value="tokenize($identificatie,'/')"/>
		    <sch:let name="type" value="$reeks[4]"/>
		
			<!-- mogelijke fout -->
            <sch:let name="fout-geen-regeling" value="common:store-error('LVBB1517',concat('[AanleveringInformatieObject - Controleer Inhoud Identificatie Regelingversie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-regeling))"/>

            <sch:assert test="$type = $type-regeling"><sch:value-of select="$fout-geen-regeling"/></sch:assert>
		</sch:rule>
	</sch:pattern>

    <!-- Als er InformatieObjectMetadata is meegegeven dan mag deze op bepaalde punten niet afwijken van eerder aangeleverde InformatieObjectMetadata -->

    <sch:pattern name="Controle aanpassingen in InformatieObjectMetadata">
        <sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:InformatieObjectMetadata">
            <sch:let name="parent" value="../data:ExpressionIdentificatie"/>
            <sch:let name="work" value="$parent/data:FRBRWork"/>
            <sch:let name="expression" value="$parent/data:FRBRExpression"/>
            <sch:let name="doc-info" value="schint:get-doc-info-for-id(node-name($parent), fn:string($expression), node-name($work), node-name($expression))"/>
            <sch:let name="join-id-werk" value="$work/string()"/>
            <sch:let name="eindverantwoordelijke" value="./data:eindverantwoordelijke/string()"/>
            <sch:let name="formaat-informatieobject" value="./data:formaatInformatieobject/string()"/>
            <sch:let name="maker" value="./data:maker/string()"/>
            <sch:let name="officiele-titel" value="./data:officieleTitel/string()"/>
            <sch:let name="opvolging" value="string-join(./data:opvolging/data:opvolgerVan/string(),',')"/>
            <sch:let name="publicatieinstructie" value="./data:publicatieinstructie/string()"/>
	        <sch:let name="meldingen" value="io:check-io-metadata-ok($join-id-werk,$doc-info,$eindverantwoordelijke,$formaat-informatieobject,$maker,$officiele-titel,$opvolging,$publicatieinstructie)"/>
	        <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>