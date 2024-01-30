  <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:xdmp="http://marklogic.com/xdmp"
     	queryBinding = "xslt2">
			
  <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/" prefix="lvbba"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/tekst/" prefix="tekst"/>
  <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/opdracht" prefix="opdracht"/>
  <sch:ns uri="http://marklogic.com/schema-validator/lib/regeling" prefix="regeling"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns uri="localFunctions" prefix="fct"/>

  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/opdracht" href="/projects/opera/repos/opera/contexts/cds/lib/opdracht.xqy"/>
  <xdmp:import-module namespace="http://marklogic.com/schema-validator/lib/regeling" href="/projects/opera/repos/opera/contexts/cds/lib/regeling.xqy"/>

	<xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
	
		<sch:let name="is-bekendmaken" value="opdracht:check-restrictie-bekendmaken(/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRExpression)"/>
	<sch:let name="akn-besluit" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
   
	<!-- Controle: Bij niet bekendmaken mag er hooguit maar 1 doel gebruikt worden in de ConsolidatieInformatie -->
	 
	<sch:pattern id="controleer-uniek-doel">
		<sch:title>Controle gebruik hooguit 1 doel</sch:title>
		<sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie[not($is-bekendmaken)]">
			<sch:let name="doelen-regelingen" value="./data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:doelen/data:doel/string()"/>
			<sch:let name="doelen-ios" value="./data:BeoogdeRegelgeving/data:BeoogdInformatieobject/data:doelen/data:doel/string()"/>
			<sch:let name="doelen-intrekkingen" value="./data:Intrekkingen/data:Intrekking/data:doelen/data:doel/string()"/>
			<sch:let name="doelen-tijdstempels" value="./data:Tijdstempels/data:Tijdstempel/data:doel/string()"/>
			<sch:let name="alle-doelen" value="($doelen-regelingen,$doelen-ios,$doelen-intrekkingen,$doelen-tijdstempels)"/>
			<sch:let name="unieke-doelen" value="distinct-values($alle-doelen)"/>
			<sch:let name="aantal-doelen" value="count($unieke-doelen)"/>
		
			<!-- mogelijke fout -->
			<sch:let name="fout-niet-uniek" value="common:store-error('LVBB4803',concat('Het besluit ', $akn-besluit,' bevat meer dan één doel (', string-join($unieke-doelen,','), '). Dat mag niet.'))"/>

			<sch:assert test="$aantal-doelen le 1"><sch:value-of select="$fout-niet-uniek"/></sch:assert>
		</sch:rule>
	</sch:pattern>

	<!-- Controle: Bij niet bekendmaken mag er hooguit maar 1 instrumentversie per instrument gebruikt worden in de ConsolidatieInformatie -->
	 
	<sch:pattern id="controleer-uniek-instrument">
		<sch:title>Controle gebruik hooguit 1 instrumentversie per instrument</sch:title>
		<sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:ConsolidatieInformatie[not($is-bekendmaken)]">
			<sch:let name="instrumentversies-regelingen" value="./data:BeoogdeRegelgeving/data:BeoogdeRegeling/data:instrumentVersie/string()"/>
			<sch:let name="instrumentversies-ios" value="./data:BeoogdeRegelgeving/data:BeoogdInformatieobject/data:instrumentVersie/string()"/>
			<sch:let name="instrumenten" value="./data:Intrekkingen/data:Intrekking/data:instrument/string()"/>
			<sch:let name="unieke-instrumentversies" value="distinct-values(($instrumentversies-regelingen,$instrumentversies-ios))"/>
			<sch:let name="unieke-instrumenten" value="distinct-values($instrumenten)"/>
			<sch:let name="meldingen" value="fct:get-meldingen-dubbelen($akn-besluit,$unieke-instrumentversies,$unieke-instrumenten)"/>
		
			<sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
		</sch:rule>
	</sch:pattern>

	<!-- Controle: Bij niet bekendmaken voor een definitief besluit moet elk vastgesteld informatie-object en elke vastgestelde regelingversie een datum jwv hebben -->

	<sch:pattern id="controleer-datum-jwv">
		<sch:title>Controle datum jwv voor elke vastgestelde regelingversie of informatie-object</sch:title>
		<sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie[ 
		                                         not(matches(data:BesluitMetadata/data:soortProcedure,'/join/id/stop/proceduretype_ontwerp')) and (not($is-bekendmaken))]/data:ConsolidatieInformatie">
			
			<sch:let name="regelingversies-consolidatie" value="./data:BeoogdeRegelgeving/data:BeoogdeRegeling"/>
			<sch:let name="regelingversies-instrumenten" value="$regelingversies-consolidatie/data:instrumentVersie/string()"/>
			<sch:let name="regelingversies-doelen" value="$regelingversies-consolidatie/data:doelen/data:doel/string()"/>
			<sch:let name="regelingversies-vastgesteld" value="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
			<sch:let name="regelingversies-vastgesteld-zonder-consolidatie" value="fct:get-ontbrekend-in-lijst($regelingversies-vastgesteld,$regelingversies-instrumenten)"/>

			<sch:let name="ios-consolidatie" value="./data:BeoogdeRegelgeving/data:BeoogdInformatieobject"/>
			<sch:let name="ios-instrumenten" value="$ios-consolidatie/data:instrumentVersie/string()"/>
			<sch:let name="ios-ext-io-refs" value="distinct-values(/lvbba:AanleveringBesluit/lvbba:BesluitVersie//(tekst:RegelingCompact | tekst:RegelingKlassiek | tekst:RegelingMutatie | tekst:RegelingTijdelijkdeel | tekst:RegelingVrijetekst)//tekst:ExtIoRef)"/>
			<sch:let name="ios-doelen" value="$ios-consolidatie/data:doelen/data:doel/string()"/>
			<sch:let name="ios-vastgesteld" value="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:BesluitMetadata/data:informatieobjectRefs/data:informatieobjectRef/string()"/>
			<sch:let name="ios-consolideerbaar-vastgesteld" value="fct:get-voorkomend-in-beide-lijsten($ios-vastgesteld,$ios-ext-io-refs)"/>
			<sch:let name="ios-vastgesteld-zonder-consolidatie" value="fct:get-ontbrekend-in-lijst($ios-consolideerbaar-vastgesteld,$ios-instrumenten)"/>

			<sch:let name="doel-tijdstempel" value="./data:Tijdstempels/data:Tijdstempel/data:doel/string()"/>
			<sch:let name="doelen-consolidatie" value="distinct-values(($regelingversies-doelen,$ios-doelen))"/>
			<sch:let name="doelen-zonder-tijdstempel" value="fct:get-ontbrekend-in-lijst($doelen-consolidatie,$doel-tijdstempel)"/>

			<sch:let name="regelingversies-zonder-doel-tijdstempel" value="fct:zoek-instrumenten-bij-doelen($doelen-zonder-tijdstempel,$regelingversies-consolidatie)"/>
			<sch:let name="regelingversies-zonder-tijdstempel" value="($regelingversies-vastgesteld-zonder-consolidatie,$regelingversies-zonder-doel-tijdstempel)"/>
			<sch:let name="meldingen-regelingversies" value="fct:get-meldingen-regelingversies-zonder-tijdstempel($regelingversies-zonder-tijdstempel)"/>

			<sch:let name="ios-zonder-doel-tijdstempel" value="fct:zoek-instrumenten-bij-doelen($doelen-zonder-tijdstempel,$ios-consolidatie)"/>
			<sch:let name="ios-zonder-tijdstempel" value="($ios-vastgesteld-zonder-consolidatie,$ios-zonder-doel-tijdstempel)"/>
			<sch:let name="meldingen-ios" value="fct:get-meldingen-ios-zonder-tijdstempel($ios-zonder-tijdstempel)"/>
		
			<sch:assert test="empty($meldingen-regelingversies)"><sch:value-of select="string-join($meldingen-regelingversies,common:get-messages-marker())"/></sch:assert>
			<sch:assert test="empty($meldingen-ios)"><sch:value-of select="string-join($meldingen-ios,common:get-messages-marker())"/></sch:assert>
		</sch:rule>
	</sch:pattern>

	<!-- Controle: Bij bekendmaken moet de eindverantwoordelijke van het besluit een ministerie zijn -->

	<sch:pattern id="controleer-bekendmaken-bij-ministerie">
		<sch:title>Controle verwerkingsrestrictie bekendmaken bij ministerire</sch:title>
		<sch:rule context="/lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:BesluitMetadata/data:eindverantwoordelijke">

			<!-- mogelijke fout -->
			<sch:let name="fout-bekendmaken-bij-decentraal" value="common:store-error('LVBB1512','U bent niet gemachtigd')"/>

			<sch:assert test="(not($is-bekendmaken)) or (matches(./string(),'/tooi/id/ministerie/'))"><sch:value-of select="$fout-bekendmaken-bij-decentraal"/></sch:assert>
		</sch:rule>
	</sch:pattern>

  <!-- Als er RegelingMetadata is meegegeven in een besluit dan mag deze op bepaalde punten niet afwijken van eerder aangeleverde RegelingMetadata -->

  <sch:pattern name="Controle aanpassingen in RegelingMetadata">
    <sch:rule context="/lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:RegelingMetadata[not($is-bekendmaken)]">
      <sch:let name="regeling-id" value="../data:ExpressionIdentificatie/data:FRBRWork/string()"/>
      <sch:let name="soort-procedure" value="../../lvbba:BesluitVersie/data:BesluitMetadata/data:soortProcedure/string()"/>
      <sch:let name="eindverantwoordelijke" value="./data:eindverantwoordelijke/string()"/>
      <sch:let name="maker" value="./data:maker/string()"/>
      <sch:let name="opvolging" value="string-join(./data:opvolging/data:opvolgerVan/string(),',')"/>
      <sch:let name="soort-regeling" value="./data:soortRegeling/string()"/>
	  <sch:let name="meldingen" value="regeling:check-regeling-metadata-ok($regeling-id,$soort-procedure,$eindverantwoordelijke,$maker,$opvolging,$soort-regeling)"/>
	  <sch:assert test="empty($meldingen)"><sch:value-of select="string-join($meldingen,common:get-messages-marker())"/></sch:assert>
    </sch:rule>
  </sch:pattern>

	<xsl:function name="fct:get-meldingen-dubbelen" as="xs:string*">
		<xsl:param name="akn-besluit" as="xs:string"/>
		<xsl:param name="instrument-expressies" as="xs:string*"/>
		<xsl:param name="instrument-werken" as="xs:string*"/>
		<xsl:variable name="instrument-werken-bij-expressies" as="xs:string*">
			<xsl:for-each select="$instrument-expressies">
				<xsl:value-of select="string-join(tokenize(.,'/')[1 to 7],'/')"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="unieke-instrument-werken" select="distinct-values(($instrument-werken,$instrument-werken-bij-expressies))"/>
		<xsl:for-each select="$unieke-instrument-werken">
			<xsl:variable name="instrument-werk" select="."/>
			<xsl:variable name="prefix-instrument-werk" select="concat($instrument-werk,'/')"/>
			<xsl:variable name="expressies-bij-instrument" select="$instrument-expressies[fn:starts-with(.,$prefix-instrument-werk)]"/>
			<xsl:variable name="werken-bij-instrument" select="$instrument-werken[. = $instrument-werk]"/>
			<xsl:variable name="alles-bij-instrument" select="($expressies-bij-instrument,$werken-bij-instrument)"/>
			<xsl:variable name="aantal" select="count($alles-bij-instrument)"/>
			<xsl:if test="$aantal gt 1">
				<xsl:variable name="type" select="tokenize($instrument-werk,'/')[2]"/>
				<xsl:variable name="naam-type">
					<xsl:choose>
						<xsl:when test="$type = 'akn'">
							<xsl:value-of select="'regeling'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'informatieobject'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="empty($werken-bij-instrument)">
						<xsl:value-of select="common:store-error('LVBB4802',concat('Het besluit ', $akn-besluit,' bevat ',$naam-type,' ', $instrument-werk, ' waarbij meer dan één ', $naam-type, 'versie (', string-join($alles-bij-instrument,','), ') wordt vastgesteld. Dat mag niet.'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="common:store-error('LVBB4804',concat('Het besluit ', $akn-besluit,' bevat ',$naam-type,' ', $instrument-werk, ' die wordt ingetrokken en een vaststelling van ', $naam-type, 'versie(s) (', string-join($expressies-bij-instrument,','), '). Dat mag niet.'))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="fct:get-ontbrekend-in-lijst" as="xs:string*">
		<xsl:param name="lijst" as="xs:string*"/>
		<xsl:param name="vergelijk-lijst" as="xs:string*"/>
		<xsl:variable name="meldingen" as="xs:string*" select="fct:check-lijsten($lijst,$vergelijk-lijst,false())"/>
		<xsl:for-each select="$meldingen">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="fct:get-voorkomend-in-beide-lijsten" as="xs:string*">
		<xsl:param name="lijst" as="xs:string*"/>
		<xsl:param name="vergelijk-lijst" as="xs:string*"/>
		<xsl:variable name="meldingen" as="xs:string*" select="fct:check-lijsten($lijst,$vergelijk-lijst,true())"/>
		<xsl:for-each select="$meldingen">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="fct:check-lijsten" as="xs:string*">
		<xsl:param name="lijst" as="xs:string*"/>
		<xsl:param name="vergelijk-lijst" as="xs:string*"/>
		<xsl:param name="wel-of-niet" as="xs:boolean"/>
		<xsl:for-each select="$lijst">
			<xsl:variable name="element" select="."/>
			<xsl:variable name="komt-voor" as="xs:string*">
				<xsl:for-each select="$vergelijk-lijst">
					<xsl:if test=". = $element">
						<xsl:value-of select="$element"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="(($wel-of-niet and not(empty($komt-voor))) or (not($wel-of-niet) and empty($komt-voor)))">
				<xsl:value-of select="$element"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="fct:zoek-instrumenten-bij-doelen" as="xs:string*">
		<xsl:param name="doelen" as="xs:string*"/>
		<xsl:param name="consolidaties" as="element()*"/>
		<xsl:for-each select="$doelen">
			<xsl:variable name="doel" select="."/>
			<xsl:for-each select="$consolidaties">
				<xsl:variable name="consolidatie" as="element()" select="."/>
				<xsl:for-each select="$consolidatie/data:doelen/data:doel/string()">
					<xsl:if test=". = $doel">
						<xsl:value-of select="$consolidatie/data:instrumentVersie/string()"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="fct:get-meldingen-regelingversies-zonder-tijdstempel" as="xs:string*">
		<xsl:param name="regelingversies" as="xs:string*"/>
		<xsl:for-each select="$regelingversies">
			<xsl:variable name="regelingversie" select="."/>
			<xsl:value-of select="common:store-error('LVBB3519',concat('Regelingversie met akn ', . ,' heeft geen datum juridisch werkend vanaf'))"/>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="fct:get-meldingen-ios-zonder-tijdstempel" as="xs:string*">
		<xsl:param name="ios" as="xs:string*"/>
		<xsl:for-each select="$ios">
			<xsl:variable name="io" select="."/>
			<xsl:value-of select="common:store-error('LVBB3518',concat('Te consolideren informatie-object ', $io,' heeft geen datum juridisch werkend vanaf'))"/>
		</xsl:for-each>
	</xsl:function>
</sch:schema> 