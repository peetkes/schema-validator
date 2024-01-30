<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">			
			
   <sch:ns uri="https://standaarden.overheid.nl/lvbb/stop/uitlevering/" prefix="lvbbu"/>
   <sch:ns uri="https://standaarden.overheid.nl/stop/imop/consolidatie/" prefix="consolidatie"/>
   <sch:ns uri="https://standaarden.overheid.nl/stop/imop/data/" prefix="data"/>
    <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>

	<xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
   
   <!-- Precies 1 voorkomen van Consolidatie binnen Consolidaties -->
   
    <sch:pattern name="Controleer voorkomen Consolidatie">
		<sch:rule context="/lvbbu:Consolidaties">
			<sch:let name="count-consolidatie" value="count(./lvbbu:Consolidatie)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-consolidatie" value="common:store-error('LVBB7728','[Controleer voorkomens Consolidatie] Aantal voorkomens van Consolidatie is niet gelijk aan 1')"/>		
			
			<sch:assert test="$count-consolidatie = 1"><sch:value-of select="$fout-consolidatie"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Precies 1 voorkomen van Toestanden binnen Consolidatie -->
   
    <sch:pattern name="Controleer voorkomen BekendeToestand / ToestandMetSamenloop">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie">
			<sch:let name="count-toestanden" value="count(./consolidatie:Toestanden)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-meerdere-toestanden" value="common:store-error('LVBB7729','[Controleer voorkomens Toestand] Aantal voorkomens van Toestand is niet gelijk aan 1')"/>		
			
			<sch:assert test="$count-toestanden = 1"><sch:value-of select="$fout-meerdere-toestanden"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Precies 1 voorkomen van BekendeToestand binnen Toestanden / ToestandMetSamenloop -->
   
    <sch:pattern name="Controleer voorkomen BekendeToestand / ToestandMetSamenloop">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden">
			<sch:let name="count-bekende-toestanden" value="count(./consolidatie:BekendeToestand)"/>
			<sch:let name="count-toestanden-met-samenloop" value="count(./consolidatie:ToestandMetSamenloop)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-meerdere-bekende-toestanden" value="common:store-error('LVBB7701','[Controleer voorkomens BekendeToestand] Aantal voorkomens van BekendeToestand is niet gelijk aan 1')"/>		
            <sch:let name="fout-toestanden-met-samenloop" value="common:store-error('LVBB7702','[Controleer voorkomens ToestandMetSamenloop] Aantal voorkomens van ToestandMetSamenloop is niet gelijk aan 0')"/>		
			
			<sch:assert test="$count-bekende-toestanden = 1"><sch:value-of select="$fout-meerdere-bekende-toestanden"/></sch:assert>
			<sch:assert test="$count-toestanden-met-samenloop = 0"><sch:value-of select="$fout-toestanden-met-samenloop"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Precies 1 voorkomen van doel binnen gerealiseerdeDoelen -->
   
    <sch:pattern name="Controleer voorkomen doel">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:BekendeToestand/consolidatie:gerealiseerdeDoelen">
			<sch:let name="count-doel" value="count(./consolidatie:doel)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-doel" value="common:store-error('LVBB7703','[Controleer voorkomens doel] Aantal voorkomens van doel is niet gelijk aan 1')"/>		
			
			<sch:assert test="$count-doel = 1"><sch:value-of select="$fout-doel"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Precies 1 voorkomen van Geldigheidsperiode binnen geldigheid -->
   
    <sch:pattern name="Controleer voorkomen Geldigheidsperiode">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:BekendeToestand/consolidatie:geldigheid">
			<sch:let name="count-periode" value="count(./consolidatie:Geldigheidsperiode)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-periode" value="common:store-error('LVBB7704','[Controleer voorkomens Geldigheidsperiode] Aantal voorkomens van Geldigheidsperiode is niet gelijk aan 1')"/>		
			
			<sch:assert test="$count-periode = 1"><sch:value-of select="$fout-periode"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Precies 1 voorkomen van AnnotatieBijToestand-->
   
    <sch:pattern name="Controleer voorkomen AnnotatieBijToestand">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie">
			<sch:let name="count-annotatie-bij-toestand" value="count(./lvbbu:AnnotatieBijToestand)"/>
			
			<!-- mogelijke foutmeldingen -->
            <sch:let name="fout-annotatie-bij-toestand" value="common:store-error('LVBB7706','[Controleer voorkomens AnnotatieBijToestand] Aantal voorkomens van AnnotatieBijToestand is niet gelijk aan 1')"/>		
			
			<sch:assert test="$count-annotatie-bij-toestand = 1"><sch:value-of select="$fout-annotatie-bij-toestand"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
   <!-- Jaar bij CVDR-id moet overeenkomen met jaar van datum juridisch-werkend-vanaf -->
   <!-- Vooralsnog uit gezet : nader beschouwen of dit wel altijd klopt -->
   
    <!-- sch:pattern name="Controleer jaren">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie">
		    <sch:let name="cvdr-id" value="./consolidatie:ConsolidatieIdentificatie/consolidatie:FRBRWork/string()"/>
			<sch:let name="jaar-cvdr-id" value="tokenize($cvdr-id,'/')[6]"/>
		    <sch:let name="expressie-cvdr-id" value="./consolidatie:Toestanden[1]/consolidatie:BekendeToestand[1]/consolidatie:FRBRExpression/string()"/>
			<sch:let name="datum-expressie-cvdr-id" value="tokenize($expressie-cvdr-id,'@')[2]"/>
			<sch:let name="datum-jwv" value="./consolidatie:Toestanden[1]/consolidatie:BekendeToestand[1]/consolidatie:geldigheid[1]/consolidatie:Geldigheidsperiode[1]/consolidatie:juridischWerkendOp/consolidatie:Periode/consolidatie:vanaf/string()"/>
			<sch:let name="jaar-datum-jwv" value="substring($datum-jwv,1,4)"/ -->
			
			<!-- mogelijke foutmeldingen -->
            <!-- sch:let name="fout-jaren" value="common:store-error('LVBB7711',concat('[Controleer jaar consolidatie] Jaar ',$jaar-cvdr-id,' in cvdr-id ',$cvdr-id, ' is niet gelijk aan jaar ',$jaar-datum-jwv,' in datum juridisch werkend vanaf ', $datum-jwv))"/>
            <sch:let name="fout-datums" value="common:store-error('LVBB7712',concat('[Controleer datum consolidatie] Datum expressie ',$datum-expressie-cvdr-id,' in cvdr-id ',$expressie-cvdr-id, ' is niet gelijk aan datum juridisch werkend vanaf ', $datum-jwv))"/>		
			
			<sch:assert test="$jaar-cvdr-id = $jaar-datum-jwv"><sch:value-of select="$fout-jaren"/></sch:assert>
			<sch:assert test="$datum-expressie-cvdr-id = $datum-jwv"><sch:value-of select="$fout-datums"/></sch:assert>
		</sch:rule>
    </sch:pattern -->
	
	<!-- datum bekend-op moet juist gevuld zijn -->
	
    <sch:pattern name="Controleer datum bekend op">
		<sch:rule context="/lvbbu:Consolidaties/lvbbu:Consolidatie/consolidatie:Toestanden/consolidatie:bekendOp">
            <sch:let name="huidige-datum" value="current-date()"/>
		    <sch:let name="datum-bekend-op" value="./string()"/>
			<sch:let name="jaar" value="substring-before($datum-bekend-op,'-')"/>
			<sch:let name="maand" value="substring-before(substring-after($datum-bekend-op,'-'),'-')"/>
			<sch:let name="dag" value="substring-after(substring-after($datum-bekend-op,'-'),'-')"/>
			
			<!-- mogelijke fouten -->
            <sch:let name="fout-onjuist-formaat" value="common:store-error('LVBB7725',concat('[Controleer Inhoud Datum Bekend op] Datum bekend op ',$datum-bekend-op,' heeft niet het formaat JJJJ-MM-DD'))"/>
			<sch:let name="fout-onjuiste-datum" value="common:store-error('LVBB7726',concat('[Controleer Inhoud Datum Bekend op] Datum bekend op ',$datum-bekend-op,' is geen juiste datum'))"/>

            <sch:assert test="string-length($datum-bekend-op) = 10 and string-length($jaar) = 4 and string-length($maand) = 2 and string-length($dag) = 2"><sch:value-of select="$fout-onjuist-formaat"/></sch:assert>
            <sch:assert test="not(string-length($datum-bekend-op) = 10) or not(string-length($jaar) = 4) or not(string-length($maand) = 2) or not(string-length($dag) = 2) or empty($datum-bekend-op) or ($datum-bekend-op castable as xs:date)"><sch:value-of select="$fout-onjuiste-datum"/></sch:assert>
		</sch:rule>
    </sch:pattern>
	
</sch:schema>