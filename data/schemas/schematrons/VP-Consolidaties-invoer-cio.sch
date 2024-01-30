<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     	queryBinding = "xslt2">			
			
   <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/uitlevering/" prefix="lvbbu"/>
   <sch:ns uri="https://standaarden.overheid.nl/stop/imop/consolidatie/" prefix="consolidatie"/>
   <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
    <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>

	<xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
   
   <!-- Precies 1 voorkomen van InformatieObjectMetadata bij AnnotatieBijToestand -->
   
    <sch:pattern name="Controleer voorkomen InformatieObjectMetadata">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:AnnotatieBijToestand">
			<sch:let name="count-informatie-object-metadata" value="count(./data:InformatieObjectMetadata)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-informatie-object-metadata" value="common:store-error('LVBB7707','[Controleer voorkomens InformatieObjectMetadata] Aantal voorkomens van InformatieObjectMetadata is niet gelijk aan 1')"/>		
			
			<sch:assert test="$count-informatie-object-metadata = 1"><sch:value-of select="$fout-informatie-object-metadata"/></sch:assert>
		</sch:rule>
    </sch:pattern>

	<!-- Controles op akn cvdr en bevoegd gezag bovenin en onderin -->
	
    <sch:pattern name="Controleer akns bovenin en onderin">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie">
		    <sch:let name="cvdr-id-werk-boven" value="./consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork/string()"/>
		    <sch:let name="cvdr-id-expressie-boven" value="./consolidatie:Toestanden[1]/consolidatie:BekendeToestand[1]/consolidatie:FRBRExpression/string()"/>
		    <sch:let name="cvdr-id-werk-onder" value="./lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:FRBRWork/string()"/>
		    <sch:let name="cvdr-id-expressie-onder" value="./lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
		    <sch:let name="akn-act-bg-werk-boven" value="./consolidatie:ConsolidatieIdentificatie/consolidatie:isConsolidatieVan/consolidatie:WorkIdentificatie/consolidatie:FRBRWork/string()"/>
		    <sch:let name="akn-act-bg-expressie-boven" value="./consolidatie:Toestanden[1]/consolidatie:BekendeToestand[1]/consolidatie:instrumentVersie/string()"/>
		    <sch:let name="akn-act-bg-werk-onder" value="./lvbbu:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRWork/string()"/>
		    <sch:let name="akn-act-bg-expressie-onder" value="./lvbbu:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRExpression/string()"/>
		    <sch:let name="cvdr-id-werk-boven-pattern" value="concat($cvdr-id-werk-boven,'/')"/>
		    <sch:let name="cvdr-id-werk-onder-pattern" value="concat($cvdr-id-werk-onder,'/')"/>
		    <sch:let name="akn-act-bg-werk-boven-pattern" value="concat($akn-act-bg-werk-boven,'/')"/>
		    <sch:let name="akn-act-bg-werk-onder-pattern" value="concat($akn-act-bg-werk-onder,'/')"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-cvdr-id-werk" value="common:store-error('LVBB7713',concat('[Controleer akn cvdr-id werk] akn van cvdr-werk bij ConsolidatieIdentificatie ',$cvdr-id-werk-boven,' is niet gelijk aan akn van cvdr-werk bij AnnotatieBijToestand ',$cvdr-id-werk-onder))"/>		
            <sch:let name="fout-cvdr-id-expressie" value="common:store-error('LVBB7714',concat('[Controleer akn cvdr-id expressie] akn van cvdr-expressie bij ConsolidatieIdentificatie ',$cvdr-id-expressie-boven,' is niet gelijk aan akn van cvdr-expressie bij AnnotatieBijToestand ',$cvdr-id-expressie-onder))"/>		
            <sch:let name="fout-akn-act-bg-werk" value="common:store-error('LVBB7715',concat('[Controleer akn bevoegd gezag werk] akn van cvdr-werk bij ConsolidatieIdentificatie ',$akn-act-bg-werk-boven,' is niet gelijk aan akn van cvdr-werk bij InformatieObjectVersie ',$akn-act-bg-werk-onder))"/>		
            <sch:let name="fout-akn-act-bg-expressie" value="common:store-error('LVBB7716',concat('[Controleer akn bevoegd gezag expressie] akn van cvdr-expressie bij Toestanden',$akn-act-bg-expressie-boven,' is niet gelijk aan akn van cvdr-expressie bij InformatieObjectVersie ',$akn-act-bg-expressie-onder))"/>		
            <sch:let name="fout-begin-werk-bovenin" value="common:store-error('LVBB7717',concat('[Controleer akn cvdr-id bovenin] akn van cvdr-werk bij ConsolidatieIdentificatie ',$cvdr-id-werk-boven,' komt niet overeeen met werk van akn van cvdr-expressie bij ConsolidatieIdentificatie ',$cvdr-id-expressie-boven))"/>		
            <sch:let name="fout-begin-werk-onderin" value="common:store-error('LVBB7718',concat('[Controleer akn cvdr-id onderin] akn van cvdr-werk bij AnnotatieBijToestand ',$cvdr-id-werk-onder,' komt niet overeeen met werk van akn van cvdr-expressie bij AnnotatieBijToestand ',$cvdr-id-expressie-onder))"/>		
            <sch:let name="fout-begin-akn-act-bovenin" value="common:store-error('LVBB7719',concat('[Controleer akn bevoegd gezag bovenin] akn van werk bevoegd gezag bij ConsolidatieIdentificatie ',$akn-act-bg-werk-boven,' komt niet overeeen met akn van expressie bevoegd gezag bij Toestanden ',$akn-act-bg-expressie-boven))"/>		
            <sch:let name="fout-begin-akn-act-onderin" value="common:store-error('LVBB7720',concat('[Controleer akn bevoegd gezag onderin] akn van werk bevoegd gezag bij InformatieObjectVersie ',$akn-act-bg-werk-onder,' komt niet overeeen met akn van expressie bevoegd gezag bij InformatieObjectVersie ',$akn-act-bg-expressie-onder))"/>		
			
			<sch:assert test="$cvdr-id-werk-boven = $cvdr-id-werk-onder"><sch:value-of select="$fout-cvdr-id-werk"/></sch:assert>
			<sch:assert test="$cvdr-id-expressie-boven = $cvdr-id-expressie-onder"><sch:value-of select="$fout-cvdr-id-expressie"/></sch:assert>
			<sch:assert test="$akn-act-bg-werk-boven = $akn-act-bg-werk-onder"><sch:value-of select="$fout-akn-act-bg-werk"/></sch:assert>
			<sch:assert test="$akn-act-bg-expressie-boven = $akn-act-bg-expressie-onder"><sch:value-of select="$fout-akn-act-bg-expressie"/></sch:assert>
			<sch:assert test="starts-with($cvdr-id-expressie-boven,$cvdr-id-werk-boven-pattern)"><sch:value-of select="$fout-begin-werk-bovenin"/></sch:assert>
			<sch:assert test="starts-with($cvdr-id-expressie-onder,$cvdr-id-werk-onder-pattern)"><sch:value-of select="$fout-begin-werk-onderin"/></sch:assert>
			<sch:assert test="starts-with($akn-act-bg-expressie-boven,$akn-act-bg-werk-boven-pattern)"><sch:value-of select="$fout-begin-akn-act-bovenin"/></sch:assert>
			<sch:assert test="starts-with($akn-act-bg-expressie-onder,$akn-act-bg-werk-onder-pattern)"><sch:value-of select="$fout-begin-akn-act-onderin"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
	<!-- Controle op soort work -->

    <sch:pattern name="Controleer soort work">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie">
		    <sch:let name="soort-work-1" value="./consolidatie:ConsolidatieIdentificatie/consolidatie:soortWork/string()"/>
		    <sch:let name="soort-work-2" value="./consolidatie:ConsolidatieIdentificatie/consolidatie:isConsolidatieVan/consolidatie:WorkIdentificatie/consolidatie:soortWork/string()"/>
		    <sch:let name="soort-work-3" value="./lvbbu:InformatieObjectVersie/data:ExpressionIdentificatie/data:soortWork/string()"/>
		    <sch:let name="soort-work-4" value="./lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:soortWork/string()"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-geen-005-1" value="common:store-error('LVBB7730',concat('[Controleer soort werk informatie-object] Soort werk ',$soort-work-1,' in ConsolidatieIdentificatie is niet gelijk aan /join/id/stop/work_005'))"/>		
            <sch:let name="fout-geen-010-1" value="common:store-error('LVBB7731',concat('[Controleer soort werk geconsolideerde informatie-object] Soort werk ',$soort-work-2,' in ConsolidatieIdentificatie is niet gelijk aan /join/id/stop/work_010'))"/>		
            <sch:let name="fout-geen-010-2" value="common:store-error('LVBB7732',concat('[Controleer soort werk informatie-object] Soort werk ',$soort-work-3,' in InformatieObjectVersie is niet gelijk aan /join/id/stop/work_010'))"/>		
            <sch:let name="fout-geen-005-2" value="common:store-error('LVBB7733',concat('[Controleer soort werk geconsolideerde informatie-object] Soort werk ',$soort-work-4,' in AnnotatieBijToestand is niet gelijk aan /join/id/stop/work_005'))"/>		
			
			<sch:assert test="$soort-work-1 = '/join/id/stop/work_005'"><sch:value-of select="$fout-geen-005-1"/></sch:assert>
			<sch:assert test="$soort-work-2 = '/join/id/stop/work_010'"><sch:value-of select="$fout-geen-010-1"/></sch:assert>
			<sch:assert test="$soort-work-3 = '/join/id/stop/work_010'"><sch:value-of select="$fout-geen-010-2"/></sch:assert>
			<sch:assert test="$soort-work-4 = '/join/id/stop/work_005'"><sch:value-of select="$fout-geen-005-2"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Extra controles op JOIN voorkomens -->
   
   <!-- alle voorkomens van JOIN moet als type 'regdata' hebben -->
   
    <sch:pattern name="Controleer JOIN aanvullend type">
 		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:FRBRWork |
						   /lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:FRBRExpression">
			<sch:let name="join" value="./string()"/>
			<sch:let name="reeks" value="tokenize($join,'/')"/>
			<sch:let name="type" value="$reeks[4]"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-type" value="common:store-error('LVBB7708',concat('[Controleer JOIN aanvullend type] join ',$join,' heeft type ',$type,' dat is niet gelijk aan ',$type-gio))"/>		
			
			<sch:assert test="$type = $type-gio"><sch:value-of select="$fout-type"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- bepaalde voorkomens van JOIN moeten een bevoegd gezag hebben -->
   
    <sch:pattern name="Controleer JOIN aanvullend bevoegd gezag">
 		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:FRBRWork |
						   /lvbbu:Consolidaties/lvbbu:Consolidatie/lvbbu:AnnotatieBijToestand/data:ExpressionIdentificatie/data:FRBRExpression">
			<sch:let name="join" value="./string()"/>
			<sch:let name="reeks" value="tokenize($join,'/')"/>
			<sch:let name="bevoegd-gezag" value="$reeks[5]"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-bevoegd-gezag" value="common:store-error('LVBB7709',concat('[Controleer JOIN aanvullend bevoegd gezag] join ',$join,' heeft een bevoegd gezag ',$bevoegd-gezag,' en dat is niet gelijk aan een waarde binnen ',string-join($gio-bevoegd-gezagen,', ')))"/>		
			
			<sch:assert test="$bevoegd-gezag = $gio-bevoegd-gezagen"><sch:value-of select="$fout-bevoegd-gezag"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
</sch:schema> 