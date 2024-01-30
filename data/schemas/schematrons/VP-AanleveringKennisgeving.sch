  <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     	queryBinding = "xslt2">			
			
  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>

	<xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
   
	<!-- Controles AKN aanvullend: controle op 'doc' ($type-kennisgeving van controle-akn-join.xsl) -->
	 
	<sch:pattern id="controle-akn-doc">
		<sch:title>Controles AKN aanvullend doc</sch:title>
		<sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:ExpressionIdentificatie/data:FRBRWork |
		                   /lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:ExpressionIdentificatie/data:FRBRExpression">
			<sch:let name="identificatie" value="./string()"/>
			<sch:let name="reeks" value="tokenize($identificatie,'/')"/>
		    <sch:let name="type" value="$reeks[4]"/>
		
				<!-- mogelijke fout -->
				<sch:let name="fout-geen-doc" value="common:store-error('LVBB4707',concat('[AanleveringKennisgeving - Controleer Inhoud Identificatie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-kennisgeving))"/>

				<sch:assert test="$type = $type-kennisgeving"><sch:value-of select="$fout-geen-doc"/></sch:assert>
		</sch:rule>
	</sch:pattern>

	<!-- Controles AKN aanvullend: controle op 'bill' bij mededelngOver ($type-bill van controle-akn-join.xsl) -->
	 
	<sch:pattern id="controle-akn-bill">
		<sch:title>Controles AKN aanvullend bill</sch:title>
		<sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:mededelingOver">
			<sch:let name="identificatie" value="./string()"/>
			<sch:let name="reeks" value="tokenize($identificatie,'/')"/>
		    <sch:let name="type" value="$reeks[4]"/>
		
				<!-- mogelijke fout -->
				<sch:let name="fout-geen-bill" value="common:store-error('LVBB4708',concat('[AanleveringKennisgeving - Controleer Inhoud Identificatie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-besluit))"/>

				<sch:assert test="$type = $type-besluit"><sch:value-of select="$fout-geen-bill"/></sch:assert>
		</sch:rule>
	</sch:pattern>

	<!-- Deze regels zijn opgenomen om de vervang en verwijder stappen in de proceduremutatie te vlaggen voor validatie, deze mogen NIET voorkomen in een kennisgeving -->
	<sch:pattern id="bevat-stappen">
		<sch:title>Controleer of er binnen Procedureverloopmutatie binnen AanleveringKennisgeving ook stappen voorkomen</sch:title>
		<sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:Procedureverloopmutatie">
			<sch:let name="voegtoe" value="./data:voegStappenToe"/>
      <sch:let name="vervang" value="./data:vervangStappen"/>
			<sch:let name="verwijder" value="./data:verwijderStappen"/>
		<sch:let name="fout-stappen" value="common:store-error('LVBB4762', concat('[AanleveringKennisgeving - Controleer Procedureverloopmutatie] Geen voegStappenToe of verwijderStappen of vervangStappen aanwezig binnen Procedureverloopmutatie'))"/>
			<sch:report test="empty($voegtoe) and empty($vervang) and empty($verwijder)"><sch:value-of select="$fout-stappen"/></sch:report>
		</sch:rule>
	</sch:pattern>

	<!-- soort kennisgeving 'KennisgevingUitspraakRechter' vooralsnog niet toelaten, het schema laat dit wel toe (user story 169953) -->
	<sch:pattern id="voorlopige-controle-soort-kennisgeving">
		<sch:title>Tijdelijke controle soort kennisgeving ongelijk aan KennisgevingUitspraakRechter of KennisgevingVoorgenomenBesluit</sch:title>
		<sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata/data:soortKennisgeving">

			<!-- mogelijke fouten -->
			<sch:let name="fout-uitspraak-rechter" value="common:store-error('LVBB4738',concat('SoortKennisgeving ','''','KennisgevingUitspraakRechter','''',' in kennisgeving mag niet gebruikt worden'))"/>

			<sch:assert test="not(./string() = 'KennisgevingUitspraakRechter')"><sch:value-of select="$fout-uitspraak-rechter"/></sch:assert>
		</sch:rule>
	</sch:pattern>

<!-- bij een KennisgevingVoorgenomenBesluit mag er geen Procedureverloopmutatie zijn -->
	<sch:pattern id="voorgenomen-besluit-mutatie-verloop">
		<sch:title>Controleer of er bij een KennisgevingVoorgenomenBesluit geen Procxedureveloopmutatie voorkomt</sch:title>
		<sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie[data:KennisgevingMetadata/data:soortKennisgeving = 'KennisgevingVoorgenomenBesluit']">
		    <sch:let name="verloop" value="./data:Procedureverloopmutatie"/>
            <sch:let name="fout-verloop" value="common:store-error('LVBB4763', concat('[AanleveringKennisgeving - Controleer Procedureverloopmutatie] Bij een KennisgevingVoorgenomenBesluit is een procedureverloopmutatie niet toegestaan'))"/>
			<sch:report test="not(empty($verloop))"><sch:value-of select="$fout-verloop"/></sch:report>
		</sch:rule>
	</sch:pattern>

	<!-- bij een KennisgevingVoorgenomenBesluit mag er geen mededelongOver zijn -->
	<sch:pattern id="voorgenomen-besluit-mededeling-over">
		<sch:title>Controleer of er bij een KennisgevingVoorgenomenBesluit geen Procxedureveloopmutatie voorkomt</sch:title>
		<sch:rule context="/lvbba:AanleveringKennisgeving/lvbba:KennisgevingVersie/data:KennisgevingMetadata[data:soortKennisgeving = 'KennisgevingVoorgenomenBesluit']">
		    <sch:let name="mededeling-over" value="./data:mededelingOver"/>
            <sch:let name="fout-mededeling-over" value="common:store-error('LVBB4740', concat('[AanleveringKennisgeving - Controleer mededelingOver] Bij een KennisgevingVoorgenomenBesluit is een mededelingOver niet toegestaan'))"/>
			<sch:report test="not(empty($mededeling-over))"><sch:value-of select="$fout-mededeling-over"/></sch:report>
		</sch:rule>
	</sch:pattern>

</sch:schema>