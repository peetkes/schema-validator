<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:data="https://standaarden.overheid.nl/stop/imop/data/"
            xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:ns prefix="geo" uri="https://standaarden.overheid.nl/stop/imop/geo/"/>
   <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
   <sch:ns prefix="basisgeo" uri="http://www.geostandaarden.nl/basisgeometrie/1.0"/>
   <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
   <sch:p>Versie 1.3.0</sch:p>
   <sch:p>Schematron voor aanvullende validatie voor imop-geo.xsd</sch:p>
   <sch:pattern id="sch_geo_001">
      <sch:title>Locatie rules</sch:title>
      <sch:rule context="geo:locaties">
         <sch:let name="aantalLocaties" value="count(./geo:Locatie)"/>
         <sch:let name="aantalLocatiesMetGroepID"
                  value="count(./geo:Locatie/geo:groepID)"/>
         <sch:let name="aantalLocatiesMetKwantitatieveNormwaarde"
                  value="count(./geo:Locatie/geo:kwantitatieveNormwaarde)"/>
         <sch:let name="aantalLocatiesMetKwalitatieveNormwaarde"
                  value="count(./geo:Locatie/geo:kwalitatieveNormwaarde)"/>
         <sch:p>Als er één locatie is in een GIO waar een waarde groepID is ingevuld MOETEN ze allemaal
        zijn ingevuld.</sch:p>
         <sch:assert id="STOP3000"
                     test="($aantalLocatiesMetGroepID = 0) or ($aantalLocatiesMetGroepID = $aantalLocaties)"
                     role="fout">
        {"code": "STOP3000", "melding": "Als er 1 locatie is in een GIO waar een waarde groepID is ingevuld moet elke locatie een GroepID hebben. Geef alle locaties een groepID.", "ernst": "fout"},</sch:assert>
         <sch:p>Als er één locatie is in een GIO waar kwantitatieveNormwaarde is ingevuld MOETEN alle
        locaties een kwantitatieveNormWaarde hebben.</sch:p>
         <sch:assert id="STOP3006"
                     test="($aantalLocatiesMetKwantitatieveNormwaarde = 0) or ($aantalLocatiesMetKwantitatieveNormwaarde = $aantalLocaties)"
                     role="fout">
        {"code": "STOP3006", "melding": "Een locatie heeft een kwantitatieveNormwaarde, en één of meerdere andere locaties niet. Geef alle locaties een kwantitatieveNormwaarde, of verwijder alle kwantitatieveNormwaardes.", "ernst": "fout"},</sch:assert>
         <sch:p>Als er één locatie is in een GIO waar kwalitatieveNormwaarde is ingevuld MOETEN alle
        locaties een kwalitatieveNormwaarde hebben.</sch:p>
         <sch:assert id="STOP3007"
                     test="($aantalLocatiesMetKwalitatieveNormwaarde = 0) or ($aantalLocatiesMetKwalitatieveNormwaarde = $aantalLocaties)"
                     role="fout">
        {"code": "STOP3007", "melding": "Een locatie heeft een kwalitatieveNormwaarde, en één of meerdere andere locaties niet. Geef alle locaties een kwalitatieveNormwaarde, of verwijder alle kwalitatieveNormwaardes.", "ernst": "fout"},</sch:assert>
         <sch:p>Als de locaties van de GIO kwantitatieve normwaarden hebben, moet de
        eenheid(eenheidlabel en eenheidID) aanwezig zijn in de GIO.</sch:p>
         <sch:report id="STOP3009"
                     test="(($aantalLocatiesMetKwantitatieveNormwaarde gt 0) and ((not(exists(../geo:eenheidlabel))) or (not(exists(../geo:eenheidID)))))"
                     role="fout">
        {"code": "STOP3009", "Work-ID": "<sch:value-of select="../geo:FRBRWork"/>", "melding": "De locaties van de GIO <sch:value-of select="../geo:FRBRWork"/> bevatten kwantitatieve normwaarden, terwijl eenheidlabel en/of eenheidID ontbreken. Vul deze aan.", "ernst": "fout"},</sch:report>
         <sch:p>Als de locaties van de GIO kwalitatieve normwaarden hebben, MOGEN eenheidlabel en
        eenheidID NIET voorkomen.</sch:p>
         <sch:report id="STOP3015"
                     test="(($aantalLocatiesMetKwalitatieveNormwaarde gt 0) and ((exists(../geo:eenheidlabel) or exists(../geo:eenheidID))))"
                     role="fout">
        {"code": "STOP3015", "Work-ID": "<sch:value-of select="../geo:FRBRWork"/>", "melding": "De GIO met Work-ID <sch:value-of select="../geo:FRBRWork"/> met kwalitatieve normwaarden, mag geen eenheidlabel noch eenheidID hebben. Verwijder eenheidlabel en eenheidID toe, of verwijder de kwalitatieve normwaarden.", "ernst": "fout"},</sch:report>
         <sch:p>Als de locaties van de GIO kwantitatieve òf kwalitatieve normwaarden hebben, dan moet
        de norm (normlabel en normID) aanwezig zijn.</sch:p>
         <sch:report id="STOP3011"
                     test="((($aantalLocatiesMetKwantitatieveNormwaarde + $aantalLocatiesMetKwalitatieveNormwaarde) gt 0) and ((not(exists(../geo:normlabel))) or (not(exists(../geo:normID)))))"
                     role="fout">
        {"code": "STOP3011", "Work-ID": "<sch:value-of select="../geo:FRBRWork"/>", "melding": "De locaties binnen GIO met Work-ID <sch:value-of select="../geo:FRBRWork"/> bevatten wel kwantitatieve òf kwalitatieve normwaarden, maar geen norm. Vul normlabel en normID aan.", "ernst": "fout"},</sch:report>
         <sch:p>Binnen 1 GIO mag elke basisgeo:id (GUID) van de geometrie van een locatie maar één keer
        voorkomen.</sch:p>
         <sch:assert id="STOP3013"
                     test="count(./geo:Locatie/geo:geometrie/basisgeo:Geometrie/basisgeo:id) = count(distinct-values(./geo:Locatie/geo:geometrie/basisgeo:Geometrie/basisgeo:id))"
                     role="fout">
        {"code": "STOP3013", "Work-ID": "<sch:value-of select="../geo:FRBRWork"/>", "melding": "In Work-ID <sch:value-of select="../geo:FRBRWork"/> zijn de basisgeo:id's niet uniek. Binnen 1 GIO mag basisgeo:id van geometrische objecten van verschillende locaties niet gelijk zijn aan elkaar. Pas dit aan.", "ernst": "fout"},</sch:assert>
      </sch:rule>
      <sch:rule context="geo:locaties/geo:Locatie">
         <sch:let name="ID" value="./geo:geometrie/basisgeo:Geometrie/basisgeo:id"/>
         <sch:p>Van de elementen kwalitatieveNormwaarde en kwantitatieveNormwaarde in een Locatie mag
        er slechts één ingevuld zijn.</sch:p>
         <sch:assert id="STOP3008"
                     test="count(./geo:kwantitatieveNormwaarde) + count(./geo:kwalitatieveNormwaarde) le 1"
                     role="fout">
        {"code": "STOP3008", "ID": "<sch:value-of select="$ID"/>", "melding": "Locatie met basisgeo:id <sch:value-of select="$ID"/> heeft zowel een kwalitatieveNormwaarde als een kwantitatieveNormwaarde. Verwijder één van beide.", "ernst": "fout"},</sch:assert>
         <sch:p>Een Locatie binnen een GIO mag niet zowel een groepID (GIO-deel) als een (kwalitatieve
        of kwantitatieve) Normwaarde bevatten.</sch:p>
         <sch:report id="STOP3012"
                     test="exists(./geo:groepID) and (exists(./geo:kwalitatieveNormwaarde) or exists(./geo:kwantitatieveNormwaarde))"
                     role="fout">
        {"code": "STOP3012", "ID": "<sch:value-of select="$ID"/>", "melding": "Locatie met basisgeo:id <sch:value-of select="$ID"/> heeft zowel een groepID (GIO-deel) als een (kwalitatieve of kwantitatieve) Normwaarde. Verwijder de Normwaarde of de groepID.", "ernst": "fout"},</sch:report>
      </sch:rule>
      <sch:rule context="geo:locaties/geo:Locatie/geo:kwalitatieveNormwaarde">
         <sch:p>Een kwalitatieveNormwaarde mag geen lege string (“”) zijn.</sch:p>
         <sch:assert id="STOP3010" test="normalize-space(.)" role="fout">
        {"code": "STOP3010", "ID": "<sch:value-of select="../geo:geometrie/basisgeo:Geometrie/basisgeo:id"/>", "melding": "De kwalitatieveNormwaarde van locatie met basisgeo:id <sch:value-of select="../geo:geometrie/basisgeo:Geometrie/basisgeo:id"/> is niet gevuld. Vul deze aan.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_geo_002">
      <sch:title>Als een locatie een groepID heeft, dan MOET deze voorkomen in het lijstje
      groepen.</sch:title>
      <sch:rule context="geo:Locatie/geo:groepID">
         <sch:let name="doelwit" value="./string()"/>
         <sch:p>Als een locatie een groepID heeft, dan MOET deze voorkomen in het lijstje
        groepen.</sch:p>
         <sch:assert id="STOP3001"
                     test="count(../../../geo:groepen/geo:Groep[./geo:groepID = $doelwit]) gt 0"
                     role="fout">
        {"code": "STOP3001", "ID": "<sch:value-of select="$doelwit"/>", "melding": "Als een locatie een groepID heeft, dan MOET deze voorkomen in het lijstje groepen. GroepID <sch:value-of select="$doelwit"/> komt niet voor in groepen. Geef alle locaties een groepID die voorkomt in groepen.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!-- STOP3002 verwijderd, schema maakt lege waarden voor groepID al onmogelijk -->
   <sch:pattern id="sch_geo_004">
      <sch:title>Check op unieke labels en groepIDs.</sch:title>
      <sch:rule context="geo:groepen">
         <sch:p>Twee groepIDs in het lijstje groepen mogen niet dezelfde waarde hebben.</sch:p>
         <sch:let name="GroepIDs">
            <xsl:for-each select="geo:Groep">
               <xsl:sort select="normalize-space(geo:groepID/./string())"/>
               <ID>
                  <xsl:value-of select="geo:groepID/string()"/>
               </ID>
            </xsl:for-each>
         </sch:let>
         <sch:let name="DubbeleGroepen">
            <xsl:for-each select="$GroepIDs/ID">
               <xsl:if test="preceding::ID[1] = .">
                  <dubbel> (<xsl:value-of select="./string()"/>, <xsl:value-of select="preceding::ID[1]/string()"/>) </dubbel>
                  <xsl:text> </xsl:text>
               </xsl:if>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="STOP3003"
                     test="normalize-space($DubbeleGroepen) = ''"
                     role="fout">
        {"code": "STOP3003", "ExpressieID": "<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>", "Dubbel": "<sch:value-of select="$DubbeleGroepen/normalize-space()"/>", "melding": "In GIO <sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/> komt groepID <sch:value-of select="$DubbeleGroepen/normalize-space()"/> meerdere keren voor. Zorg dat iedere Groep een uniek ID heeft.", "ernst": "fout"},</sch:assert>
         <sch:let name="Labels">
            <xsl:for-each select="geo:Groep">
               <xsl:sort select="normalize-space(geo:label/./string())"/>
               <naam>
                  <xsl:value-of select="geo:label"/>
               </naam>
            </xsl:for-each>
         </sch:let>
         <sch:let name="DubbeleLabels">
            <xsl:for-each select="$Labels/naam">
               <xsl:if test="preceding::naam[1] = ."> (<xsl:value-of select="./string()"/>, <xsl:value-of select="preceding::naam[1]/string()"/>) </xsl:if>
               <xsl:text> </xsl:text>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="STOP3004"
                     test="normalize-space($DubbeleLabels) = ''"
                     role="fout">
        {"code": "STOP3004", "ExpressieID": "<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>", "Dubbel": "<sch:value-of select="$DubbeleLabels/normalize-space()"/>", "melding": "In GIO <sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/> komt label <sch:value-of select="$DubbeleLabels/normalize-space()"/> meerdere keren voor. Geef een unieke labels.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_geo_005">
      <sch:title>Als een groepID voorkomt in het lijstje groepen dan MOET er minstens 1 locatie zijn
      met dat groepID.</sch:title>
      <sch:rule context="geo:groepen/geo:Groep/geo:groepID">
         <sch:let name="doelwit" value="./string()"/>
         <sch:p>Als een groepID voorkomt in het lijstje groepen dan MOET er minstens 1 locatie zijn met
        dat groepID.</sch:p>
         <sch:assert id="STOP3005"
                     test="count(../../../geo:locaties/geo:Locatie[./geo:groepID = $doelwit]) gt 0"
                     role="fout">
        {"code": "STOP3005", "ID": "<sch:value-of select="$doelwit"/>", "melding": "GroepID <sch:value-of select="$doelwit"/> wordt niet gebruikt voor een locatie. Verwijder deze groep, of gebruik de groep bij een Locatie.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_geo_006">
      <sch:title>Geen norm elementen in een GIO zonder normwaarde.</sch:title>
      <sch:rule context="geo:GeoInformatieObjectVersie">
         <sch:p>In een GIO waar locaties geen kwalitatieve of kwantitatieve normwaarde hebben, MOGEN
        eenheidID, eenheidlabel, normID en normlabel NIET voorkomen.</sch:p>
         <sch:report id="STOP3016"
                     test="(exists(geo:normID) or exists(geo:normlabel) or exists(geo:eenheidID) or exists(geo:eenheidlabel)) and (count(geo:locaties/geo:Locatie/geo:kwantitatieveNormwaarde) + count(geo:locaties/geo:Locatie/geo:kwalitatieveNormwaarde) = 0)"
                     role="fout">
       {"code": "STOP3016", "Work-ID": "<sch:value-of select="geo:FRBRWork"/>", "melding": "De GIO met Work-ID <sch:value-of select="geo:FRBRWork"/> bevat norm (normID en normlabel) en/of eenheid (eenheidID en eenheidlabel), terwijl kwantitatieve of kwalitatieve normwaarden ontbreken. Geef de locaties normwaarden of verwijder de norm/eenheid-elementen.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <!-- STOP3017 verwijderd -->
   <!-- STOP3018 kan niet gevalideerd worden -->
   <sch:pattern id="sch_basisgeo_001">
      <sch:title>Locaties in een GIO MOETEN een geometrie hebben. (basisgeo:geometrie in
      basisgeo:Geometrie MAG NIET ontbreken of leeg zijn).</sch:title>
      <sch:rule context="basisgeo:geometrie">
         <sch:let name="coordinaten">
            <xsl:for-each select=".//gml:posList | .//gml:pos | .//gml:coordinates">
               <xsl:value-of select="./string()"/>
               <xsl:text> </xsl:text>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="STOP3019"
                     test="(descendant::gml:pos or descendant::gml:posList or descendant::gml:coordinates) and matches($coordinaten, '\d')"
                     role="fout"> 
        {"code": "STOP3019", "locatienaam": "<sch:value-of select="ancestor::geo:Locatie/geo:naam"/>", "basisgeo:id": "<sch:value-of select="preceding-sibling::basisgeo:id"/>", "ExpressieID": "<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>", "melding": "Een locatie(<sch:value-of select="ancestor::geo:Locatie/geo:naam"/>) in de GIO(<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/> heeft geen of een lege basisgeo:geometrie(<sch:value-of select="preceding-sibling::basisgeo:id"/>). Een locatie zonder geometrische data is niet toegestaan. Voeg een (correcte) basisgeo:geometrie toe.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_gml_001">
      <sch:title>Coördinaten in geometrieen in een GIO MOETEN gebruik maken van het RD of ETRS89
      ruimtelijke referentiesysteem(srsName='urn:ogc:def:crs:EPSG::28992' of
      srsName='urn:ogc:def:crs:EPSG::4258').</sch:title>
      <sch:rule context="gml:*[@srsName]">
         <sch:assert id="STOP3020"
                     test="@srsName = 'urn:ogc:def:crs:EPSG::28992' or @srsName = 'urn:ogc:def:crs:EPSG::4258'"
                     role="fout">
                    {"code": "STOP3020", "srsName": "<sch:value-of select="@srsName"/>", "ExpressieID": "<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>", "melding": "De GIO(<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>) bevat een geometrisch object met een ongeldige srsName (<sch:value-of select="@srsName"/>). Alleen srsName='urn:ogc:def:crs:EPSG::28992' of srsName='urn:ogc:def:crs:EPSG::4258' is toegestaan. Wijzig de srsName.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_gml_002">
      <sch:title>Alle srsNames identiek</sch:title>
      <sch:rule context="geo:locaties">
         <sch:let name="srsName" value="//@srsName"/>
         <sch:assert id="STOP3021"
                     test="count(distinct-values(//@srsName)) = 1"
                     role="fout">
        {"code": "STOP3021", "srsNames": "<sch:value-of select="distinct-values($srsName)"/>", "ExpressieID": "<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>", "melding": "In GIO(<sch:value-of select="ancestor::geo:GeoInformatieObjectVersie/geo:FRBRExpression"/>) heeft niet elk geometrisch object dezelfde srsName (<sch:value-of select="distinct-values($srsName)"/>). Dit is niet toegestaan. Zorg ervoor dat elke geometrisch object in de GIO hetzelfde ruimtelijke referentiesysteem(srsName) gebruikt.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_gml_003">
      <sch:title>Geen optionele gml elementen in geo:GeoInformatieObjectVaststelling,
      geo:GeoInformatieObjectVersie en geo:Locatie</sch:title>
      <sch:rule context="gml:metaDataProperty | gml:description | gml:descriptionReference | gml:identifier | gml:name | gml:boundedBy | gml:location | gml:PriorityLocation">
         <sch:report id="STOP3090"
                     test="contains('GeoInformatieObjectVaststelling|GeoInformatieObjectVersie|Locatie', string(local-name(..)))"
                     role="fout">
        {"code": "STOP3090", "ExpressieID": "<sch:value-of select="ancestor::geo:GeoInformatieObjectVaststelling/descendant::geo:FRBRExpression"/>", "Element": "<sch:value-of select="string(node-name(.))"/>", "Parent": "<sch:value-of select="string(node-name(..))"/>", "melding": "GIO <sch:value-of select="ancestor::geo:GeoInformatieObjectVaststelling/descendant::geo:FRBRExpression"/> bevat het optionele gml-element <sch:value-of select="string(node-name(.))"/> binnen <sch:value-of select="string(node-name(..))"/>. Dit element mag niet worden gebruikt in een GIO. Verwijder dit element.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
</sch:schema>
