<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
    <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/uitlevering/" prefix="lvbbu"/>
    <sch:ns uri="https://standaarden.overheid.nl/stop/imop/consolidatie/" prefix="consolidatie"/>
    <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
    <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
    <sch:ns uri="https://standaarden.overheid.nl/stop/imop/geo/" prefix="geo"/>
    <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
    <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
	
	<xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>

    <!-- Algemene schematron controles die voor alle types document gelden  -->

    <!-- Waardelijsten voor AKN en JOIN -->

    <sch:pattern name="Properties">
        <sch:let name="soorten" value="('akn','join')"/>
    </sch:pattern>
	
	<!-- De meeste controles binnen //data:ExpressionIdentificatie/data:FRBRWork en //data:ExpressionIdentificatie/data:FRBRExpression worden gedaan door imop-aknjoin.sch -->
	
    <!-- Beperkte controles juiste opbouw AKN of JOIN van werk binnen //data:ExpressionIdentificatie/data:FRBRWork -->

    <sch:pattern name="Controleer juiste opbouw AKN of JOIN - Werk">
		<sch:rule context="//data:ExpressionIdentificatie/data:FRBRWork">
		    <sch:let name="invoer" value="./string()"/>
            <sch:let name="reeks" value="tokenize($invoer,'/')"/>
            <sch:let name="akn" value="$reeks[2]"/>
			
			<sch:let name="meldingen" value="if ($akn='akn') then akn-join:controle-akn-werk-beperkt($invoer,'werk') else if ($akn='join') then akn-join:controle-join-werk-beperkt($invoer,'werk') else ()"/>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Beperkte controles juiste opbouw AKN of JOIN van expressie binnen //data:ExpressionIdentificatie/data:FRBRExpression -->

    <sch:pattern name="Controleer juiste opbouw AKN of JOIN - Expressie">
		<sch:rule context="//data:ExpressionIdentificatie/data:FRBRExpression">
		    <sch:let name="invoer" value="./string()"/>
            <sch:let name="reeks" value="tokenize($invoer,'/')"/>
            <sch:let name="akn" value="$reeks[2]"/>
			
			<sch:let name="meldingen" value="if ($akn='akn') then akn-join:controle-akn-expressie-beperkt($invoer) else if ($akn='join') then akn-join:controle-join-expressie-beperkt($invoer) else ()"/>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Controle juiste opbouw AKN of JOIN van werk -->

    <sch:pattern name="Controleer juiste opbouw AKN of JOIN - Werk">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork |
						   /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:WorkIdentificatie/consolidatie:FRBRWork |
						   /lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:Intrekkingen/data:Intrekking/data:instrument">
		    <sch:let name="invoer" value="./string()"/>
            <sch:let name="reeks" value="tokenize($invoer,'/')"/>
            <sch:let name="akn" value="$reeks[2]"/>
			
			<!-- mogelijke foutmelding -->
            <sch:let name="fout-geen-akn-of-join" value="common:get-message('LVBB2008',('[Controleer juiste opbouw AKN of JOIN - Werk - eerste string]',$akn,$invoer,concat('een waarde binnen ',string-join($soorten,','))))"/>			
			
			<sch:let name="meldingen" value="if ($akn='akn') then akn-join:controle-akn-werk($invoer,'werk') else if ($akn='join') then akn-join:controle-join-werk($invoer,'werk') else ()"/>
            <sch:assert test="$akn = $soorten"><sch:value-of select="$fout-geen-akn-of-join"/></sch:assert>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Controle juiste opbouw AKN of JOIN van expressie -->

    <sch:pattern name="Controleer juiste opbouw AKN of JOIN - Expressie">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:BekendeToestand/consolidatie:FRBRExpression |
						   /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:BekendeToestand/consolidatie:instrumentVersie">
		    <sch:let name="invoer" value="./string()"/>
            <sch:let name="reeks" value="tokenize($invoer,'/')"/>
            <sch:let name="akn" value="$reeks[2]"/>
			
			<!-- mogelijke foutmelding -->
            <sch:let name="fout-geen-akn-of-join" value="common:get-message('LVBB2008',('[Controleer juiste opbouw AKN of JOIN - Expressie - eerste string]',$akn,$invoer,concat('een waarde binnen ',string-join($soorten,','))))"/>			
			
			<sch:let name="meldingen" value="if ($akn='akn') then akn-join:controle-akn-expressie($invoer) else if ($akn='join') then akn-join:controle-join-expressie($invoer) else ()"/>
            <sch:assert test="$akn = $soorten"><sch:value-of select="$fout-geen-akn-of-join"/></sch:assert>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Controle juiste opbouw AKN werk -->

    <sch:pattern name="Controleer juiste opbouw AKN - Werk">
		<sch:rule context="/lvbba:AanleveringInformatieObject/lvbba:InformatieObjectVersie/data:InformatieObjectVersieMetadata/data:heeftGeboorteregeling |
						   /lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:RegelingMetadata/data:opvolging/data:opvolgerVan |
						   /lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:isTijdelijkDeelVan/data:WorkIdentificatie/data:FRBRWork |
						   /lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:ConsolidatieIdentificatie/consolidatie:isTijdelijkDeelVan/consolidatie:WorkIdentificatie/consolidatie:FRBRWork">
            <sch:let name="werk" value="./string()"/>
			<sch:let name="meldingen" value="akn-join:controle-akn-werk($werk,'werk')"/>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Controle juiste opbouw AKN expressie -->
	<!-- Opgesplitst in 2 delen omdat de context maar een beperkte lengte mag hebben -->

    <sch:pattern name="Controleer juiste opbouw AKN - Expressie - deel 1">
		<sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingCompact[not(empty(@wordt))] |
                           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitKlassiek/tekst:RegelingKlassiek[not(empty(@wordt))] |
                           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingVrijetekst[not(empty(@wordt))] |
                           /lvbba:AanleveringBesluit/lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage/tekst:RegelingTijdelijkdeel[not(empty(@wordt))]">
            <sch:let name="expressie" value="@wordt"/>
			<sch:let name="meldingen" value="akn-join:controle-akn-expressie($expressie)"/>
			<sch:let name="meldingen-was" value="if (empty(@was)) then () else akn-join:controle-akn-expressie(@was)"/>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
            <sch:assert test="empty($meldingen-was)"><sch:value-of select="string-join($meldingen-was,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern name="Controleer juiste opbouw AKN - Expressie - deel 2">
		<sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:instrumentVersie |
                           /lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:mededelingOver">
            <sch:let name="expressie" value="./string()"/>
			<sch:let name="meldingen" value="akn-join:controle-akn-expressie($expressie)"/>
            <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Controle juiste opbouw JOIN werk -->

    <sch:pattern name="Controleer juiste opbouw JOIN - Werk">
        <sch:rule context="/geo:GeoInformatieObjectVaststelling/geo:vastgesteldeVersie/geo:GeoInformatieObjectVersie/geo:FRBRWork |
		                   /lvbba:AanleveringInformatieObject/data:InformatieObjectMetadata/data:officieleTitel">
            <sch:let name="meldingen" value="akn-join:controle-join-werk(.,'werk')"/>
		    <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>
	
    <!-- Controle juiste opbouw JOIN expressie -->

    <sch:pattern name="Controleer juiste opbouw JOIN - Expressie">
        <sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:BesluitMetadata/data:informatieobjectRefs/data:informatieobjectRef |
						   /lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie/data:BeoogdeRegelgeving/data:BeoogdInformatieobject/data:instrumentVersie |
		                   /geo:GeoInformatieObjectVaststelling/geo:vastgesteldeVersie/geo:GeoInformatieObjectVersie/geo:FRBRExpression |
		                   /lvbba:AanleveringInformatieObject/data:InformatieObjectMetadata/data:opvolging/data:opvolgerVan">
            <sch:let name="meldingen" value="akn-join:controle-join-expressie(.)"/>
		    <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- Controle juiste opbouw JOIN werk of expressie -->
	
    <sch:pattern name="Controleer juiste opbouw JOIN - Werk of Expressie">
        <sch:rule context="//tekst:ExtIoRef">
            <sch:let name="content" value="./string()"/>
            <sch:let name="ref" value="./@ref/string()"/>
            <sch:let name="meldingen-content" value="if (contains($content,'@')) then akn-join:controle-join-expressie($content) else akn-join:controle-join-werk($content,'werk')"/>
            <sch:let name="meldingen-ref" value="if (contains($ref,'@')) then akn-join:controle-join-expressie($ref) else akn-join:controle-join-werk($ref,'werk')"/>
            <sch:assert test="empty($meldingen-content)"><sch:value-of select="string-join($meldingen-content,common:get-messages-marker())"/></sch:assert>
            <sch:assert test="empty($meldingen-ref)"><sch:value-of select="string-join($meldingen-ref,common:get-messages-marker())"/></sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>