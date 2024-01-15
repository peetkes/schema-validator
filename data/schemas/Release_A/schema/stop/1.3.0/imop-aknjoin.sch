<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:data="https://standaarden.overheid.nl/stop/imop/data/"
            xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:ns prefix="data" uri="https://standaarden.overheid.nl/stop/imop/data/"/>
   <sch:ns prefix="geo" uri="https://standaarden.overheid.nl/stop/imop/geo/"/>
   <sch:ns prefix="cons"
           uri="https://standaarden.overheid.nl/stop/imop/consolidatie/"/>
   <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
   <sch:p>Versie 1.3.0</sch:p>
   <sch:p>Schematron voor aanvullende validatie van de regels voor AKNs en JOINs</sch:p>
   <sch:pattern id="sch_data_001">
      <sch:title>AKN- of JOIN-identificatie mag geen punt bevatten</sch:title>
      <sch:rule context="*:FRBRWork | *:FRBRExpression | *:instrumentVersie | *:ExtIoRef | *:opvolgerVan | *:informatieobjectRef | *:instrument | *:heeftGeboorteregeling">
         <sch:p>Een AKN- of JOIN-identificatie mag geen punt bevatten</sch:p>
         <sch:report id="STOP1000" test="contains(., '.')" role="fout">
        {"code": "STOP1000", "ID": "<sch:value-of select="."/>", "melding": "De identifier <sch:value-of select="."/> bevat een punt. Dit is niet toegestaan. Verwijder de punt.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_002">
      <sch:title>ExpressionID begint met WorkID</sch:title>
      <sch:rule context="*:ExpressionIdentificatie | geo:GeoInformatieObjectVersie">
         <sch:let name="Work" value="normalize-space(*:FRBRWork)"/>
         <sch:let name="Expression" value="normalize-space(*:FRBRExpression)"/>
         <sch:p>Het deel vóór de @ van de FRBRExpression moet gelijk aan zijn FRBRWork</sch:p>
         <sch:assert id="STOP1001"
                     test="starts-with($Expression, concat($Work, '/'))"
                     role="fout">
        {"code": "STOP1001", "Work-ID": "<sch:value-of select="$Work"/>", "Expression-ID": "<sch:value-of select="$Expression"/>", "melding": "Het gedeelte van de FRBRExpression <sch:value-of select="$Expression"/> vóór de 'taalcode/@' is niet gelijk aan de FRBRWork-identificatie <sch:value-of select="$Work"/>.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_003">
      <sch:title>validatie van de eerste twee delen van de akn of join identificaties</sch:title>
      <sch:rule context="*:FRBRWork | *:FRBRExpression | *:instrumentVersie | *:ExtIoRef | *:opvolgerVan | *:informatieobjectRef | *:instrument | *:opvolgerVan">
         <sch:let name="Identificatie" value="./string()"/>
         <sch:let name="Identificatie_reeks" value="tokenize($Identificatie, '/')"/>
         <sch:let name="Identificatie_deel2" value="$Identificatie_reeks[3]"/>
         <sch:let name="land_expressie" value="'^(nl|aw|cw|sx)$'"/>
         <sch:let name="id_expressie" value="'^(id)$'"/>
         <sch:p>Een AKN of JOIN identificatie MOET starten met /akn/ of /join/</sch:p>
         <sch:assert id="STOP1014"
                     test="starts-with(./normalize-space(), '/akn/') or starts-with(./normalize-space(), '/join/')"
                     role="fout">
        {"code": "STOP1014", "ID": "<sch:value-of select="."/>", "melding": "De waarde <sch:value-of select="."/> begint niet met /akn/ of /join/. Pas de waarde aan.", "ernst": "fout"},</sch:assert>
         <sch:p>AKN-identificatie MOET als tweede deel een geldig land hebben</sch:p>
         <sch:report id="STOP1002"
                     test="starts-with(./normalize-space(), '/akn/') and not(matches($Identificatie_deel2, $land_expressie))"
                     role="fout">
	    {"code": "STOP1002", "Work-ID": "<sch:value-of select="./string()"/>", "substring": "<sch:value-of select="$Identificatie_deel2"/>", "melding": "Landcode <sch:value-of select="$Identificatie_deel2"/> in de AKN-identificatie <sch:value-of select="./string()"/> is niet toegestaan. Pas landcode aan.", "ernst": "fout"},</sch:report>
         <sch:p>JOIN-identificatie MOET als tweede deel een geldig objecttype hebben</sch:p>
         <sch:report id="STOP1003"
                     test="starts-with(./normalize-space(), '/join/') and not(matches($Identificatie_deel2, $id_expressie))"
                     role="fout">
	    {"code": "STOP1003", "Work-ID": "<sch:value-of select="./string()"/>", "melding": "Tweede deel JOIN-identificatie <sch:value-of select="./string()"/> moet gelijk zijn aan 'id'. Pas dit aan.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_005">
      <sch:title>AKN/JOIN validaties Expression/Work icm soortWork in
      ExpressionIdentificatie</sch:title>
      <sch:rule context="*:ExpressionIdentificatie">
         <sch:let name="soortWork" value="./*:soortWork/string()"/>
         <sch:let name="Expression" value="./*:FRBRExpression/string()"/>
         <sch:let name="Work" value="./*:FRBRWork/string()"/>
         <sch:let name="is_Expression" value="./*:FRBRExpression"/>
         <sch:let name="Expression_reeks" value="tokenize($Expression, '/')"/>
         <sch:let name="Expression_objecttype" value="$Expression_reeks[3]"/>
         <sch:let name="Expression_land" value="$Expression_reeks[3]"/>
         <sch:let name="Expression_collectie" value="$Expression_reeks[4]"/>
         <sch:let name="Expression_documenttype" value="$Expression_reeks[4]"/>
         <sch:let name="Expression_overheid" value="$Expression_reeks[5]"/>
         <sch:let name="Expression_datum_work" value="$Expression_reeks[6]"/>
         <sch:let name="Expression_restdeel" value="$Expression_reeks[8]"/>
         <sch:let name="Expression_restdeel_reeks"
                  value="tokenize($Expression_restdeel, '@')"/>
         <sch:let name="Expression_taal" value="$Expression_restdeel_reeks[1]"/>
         <sch:let name="Expression_restdeel_deel2" value="$Expression_restdeel_reeks[2]"/>
         <sch:let name="Expression_restdeel_deel2_reeks"
                  value="tokenize($Expression_restdeel_deel2, ';')"/>
         <sch:let name="Expression_datum_expr"
                  value="$Expression_restdeel_deel2_reeks[1]"/>
         <sch:let name="Work_reeks" value="tokenize($Work, '/')"/>
         <sch:let name="Work_objecttype" value="$Work_reeks[3]"/>
         <sch:let name="Work_land" value="$Work_reeks[3]"/>
         <sch:let name="Work_collectie" value="$Work_reeks[4]"/>
         <sch:let name="Work_documenttype" value="$Work_reeks[4]"/>
         <sch:let name="Work_overheid" value="$Work_reeks[5]"/>
         <sch:let name="Work_datum_work" value="$Work_reeks[6]"/>
         <sch:let name="componentdeel" value="$Expression_reeks[9]"/>
         <sch:let name="is_besluit" value="$soortWork = '/join/id/stop/work_003'"/>
         <sch:let name="is_kennisgeving" value="$soortWork = '/join/id/stop/work_023'"/>
         <sch:let name="is_rectificatie" value="$soortWork = '/join/id/stop/work_018'"/>
         <sch:let name="is_tijdelijkregelingdeel"
                  value="$soortWork = '/join/id/stop/work_021'"/>
         <sch:let name="is_regeling"
                  value="$soortWork = '/join/id/stop/work_019' or $soortWork = '/join/id/stop/work_006' or $soortWork = '/join/id/stop/work_021' or $soortWork = '/join/id/stop/work_022'"/>
         <sch:let name="is_publicatie" value="$soortWork = '/join/id/stop/work_015'"/>
         <sch:let name="is_informatieobject"
                  value="$soortWork = '/join/id/stop/work_010'"/>
         <sch:let name="is_cons_informatieobject"
                  value="$soortWork = '/join/id/stop/work_005'"/>
         <sch:let name="overheidexpressie"
                  value="'^(mnre\d{4}|mn\d{3}|gm\d{4}|ws\d{4}|pv\d{2})$'"/>
         <sch:let name="consolidatieExpressieAKN"
                  value="'^(land|provincie|gemeente|waterschap|consolidatie)$'"/>
         <sch:let name="consolidatieExpressieJOIN" value="'^consolidatie$'"/>
         <sch:let name="bladcode" value="'^(bgr|gmb|prb|stb|stcrt|trb|wsb)$'"/>
         <sch:let name="taalexpressie" value="'^(nld|eng|fry|pap|mul|und)$'"/>
         <sch:let name="collectieexpressie" value="'^(regdata|infodata|pubdata)$'"/>
         <sch:let name="is_join" value="$is_informatieobject"/>
         <sch:let name="is_akn"
                  value="$is_besluit or $is_publicatie or $is_regeling or $is_kennisgeving or $is_rectificatie"/>
         <sch:p>AKN-identificatie (Work) van officiele publicatie MOET als derde deel officialGazette
        hebben</sch:p>
         <sch:report id="STOP1011"
                     test="$is_publicatie and not(matches($Work_documenttype, '^officialGazette$'))"
                     role="fout">
	    {"code": "STOP1011", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_documenttype"/>", "melding": "Derde veld <sch:value-of select="$Work_documenttype"/> in de AKN-identificatie <sch:value-of select="$Work"/> is niet toegestaan bij officiele publicatie. Pas dit veld aan.", "ernst": "fout"},</sch:report>
         <sch:p>AKN-identificatie (Work) van besluit MOET als derde deel bill hebben</sch:p>
         <sch:report id="STOP1013"
                     test="$is_besluit and not(matches($Work_documenttype, '^bill$'))"
                     role="fout">
	    {"code": "STOP1013", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_documenttype"/>", "melding": "Derde veld <sch:value-of select="$Work_documenttype"/> in de AKN-identificatie <sch:value-of select="$Work"/> is niet toegestaan bij besluit. Pas dit veld aan.", "ernst": "fout"},</sch:report>
         <sch:p>AKN-identificatie (work) van (evt gecons) regeling of tijdelijkregelingdeel MOET als
        derde deel act hebben</sch:p>
         <sch:report id="STOP1012"
                     test="$is_regeling and not(matches($Work_documenttype, '^act$'))"
                     role="fout">
	    {"code": "STOP1012", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_documenttype"/>", "melding": "Derde veld <sch:value-of select="$Work_documenttype"/> in de AKN-identificatie <sch:value-of select="$Work"/> is niet toegestaan bij regeling. Pas dit veld aan.", "ernst": "fout"},</sch:report>
         <sch:p>JOIN-identificatie (werk) MOET als derde deel regdata,pubdata, infodata hebben</sch:p>
         <sch:report id="STOP1004"
                     test="$is_join and not(matches($Work_collectie, $collectieexpressie))"
                     role="fout">
	  	{"code": "STOP1004", "Work-ID": "<sch:value-of select="$Work"/>", "melding": "Derde deel JOIN-identificatie <sch:value-of select="$Work"/> moet gelijk zijn aan regdata, pubdata, of infodata. Pas dit aan.", "ernst": "fout"},</sch:report>
         <sch:p>AKN of JOIN identificatie MOET als vijfde deel jaartal of geldigde datum hebben</sch:p>
         <sch:report id="STOP1006"
                     test="($is_join or $is_akn) and not(($Work_datum_work castable as xs:date) or ($Work_datum_work castable as xs:gYear))"
                     role="fout">
		  {"code": "STOP1006", "Work-ID": "<sch:value-of select="$Work"/>", "melding": "Vijfde deel AKN- of JOIN-identificatie <sch:value-of select="$Work"/> moet gelijk zijn aan jaartal of geldige datum. Pas dit aan.", "ernst": "fout"},</sch:report>
         <sch:p>JOIN-identificatie (expressie) MOET als eerste deel na de '@' een jaartal of een
        geldige datum hebben</sch:p>
         <sch:report id="STOP1007"
                     test="$is_join and not(($Expression_datum_expr castable as xs:date) or ($Expression_datum_expr castable as xs:gYear))"
                     role="fout">
		  {"code": "STOP1007", "Expression-ID": "<sch:value-of select="$Expression"/>", "melding": "Voor een JOIN-identificatie (<sch:value-of select="$Expression"/>) moet het eerste deel na de '@' een jaartal of een geldige datum zijn. Pas dit aan.", "ernst": "fout"},</sch:report>
         <sch:p>JOIN-identificatie (expressie) MOET als eerste deel na de '@' een jaartal of een
        geldige datum hebben groter/gelijk aan jaartal in werk</sch:p>
         <sch:report id="STOP1008"
                     test="$is_join and not($Expression_datum_expr &gt;= $Expression_datum_work)"
                     role="fout"> 
		  {"code": "STOP1008", "Work-ID": "<sch:value-of select="$Work"/>", "Expression-ID": "<sch:value-of select="$Expression"/>", "melding": "JOIN-identificatie (<sch:value-of select="$Expression"/>) MOET als eerste deel na de '@' een jaartal of een geldige datum hebben groter/gelijk aan jaartal in werk (<sch:value-of select="$Work"/>). Pas dit aan.", "ernst": "fout"},</sch:report>
         <sch:p>AKN- of JOIN-identificatie (expressie) MOET als deel voorafgaand aan de '@' een geldige
        taal hebben</sch:p>
         <sch:report id="STOP1009"
                     test="($is_join or $is_akn) and not(matches($Expression_taal, $taalexpressie))"
                     role="fout">
		  {"code": "STOP1009", "Expression-ID": "<sch:value-of select="$Expression"/>", "substring": "<sch:value-of select="$Expression_taal"/>", "melding": "Voor een AKN- of JOIN-identificatie (<sch:value-of select="$Expression"/>) moet deel voorafgaand aan de '@' (<sch:value-of select="$Expression_taal"/>) een geldige taal zijn ('nld','eng','fry','pap','mul','und'). Pas dit aan.", "ernst": "fout"},</sch:report>
         <sch:p>Vierde deel AKN werken m.u.v. offpub MOET brp-code of code voor geconsolideerde regeling zijn.</sch:p>
         <sch:report id="STOP1010"
                     test="($is_akn and not($is_publicatie) and         not(matches($Work_overheid, $overheidexpressie) or matches($Work_overheid, $consolidatieExpressieAKN))) or         ($is_join and not($is_publicatie) and         not(matches($Work_overheid, $overheidexpressie) or matches($Work_overheid, $consolidatieExpressieJOIN)))"
                     role="fout">
		  {"code": "STOP1010", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_overheid"/>", "melding": "Vierde deel van AKN/JOIN van werk (<sch:value-of select="$Work"/>) moet gelijk zijn aan een brp-code of code voor geconsolideerde instrumenten. Pas (<sch:value-of select="$Work_overheid"/>) aan.", "ernst": "fout"},</sch:report>
         <sch:p>Vierde deel AKN van offpub werken MOET bladcode zijn</sch:p>
         <sch:report id="STOP1017"
                     test="$is_publicatie and not(matches($Work_overheid, $bladcode))"
                     role="fout"> 
		  {"code": "STOP1017", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_overheid"/>", "melding": "Vierde veld <sch:value-of select="$Work_overheid"/> in de AKN-identificatie <sch:value-of select="$Work"/> is niet toegestaan bij officiele publicatie. Pas dit veld aan.", "ernst": "fout"},</sch:report>
         <sch:p>AKN-identificatie van een kennisgeving MOET als derde deel doc hebben</sch:p>
         <sch:report id="STOP1037"
                     test="$is_kennisgeving and not(matches($Work_documenttype, '^doc$'))"
                     role="fout">
	    {"code": "STOP1037", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_documenttype"/>", "melding": "Derde veld <sch:value-of select="$Work_documenttype"/> in de AKN-identificatie <sch:value-of select="$Work"/> is niet toegestaan voor een kennisgeving. Pas dit veld aan.", "ernst": "fout"},</sch:report>
         <sch:p>AKN-identificatie van een rectificatie MOET als derde deel doc hebben</sch:p>
         <sch:report id="STOP1044"
                     test="$is_rectificatie and not(matches($Work_documenttype, '^doc$'))"
                     role="fout">
	    {"code": "STOP1044", "Work-ID": "<sch:value-of select="$Work"/>", "substring": "<sch:value-of select="$Work_documenttype"/>", "melding": "Derde deel <sch:value-of select="$Work_documenttype"/> in de AKN-identificatie <sch:value-of select="$Work"/> is niet toegestaan voor een rectificatie. Pas dit deel aan.", "ernst": "fout"},</sch:report>
         <sch:p>Als FRBRWork begint met '/akn/nl/bill/' dan moet het soortwork '/join/id/stop/work_003'
        (generiek besluit) zijn.</sch:p>
         <sch:report id="STOP2002"
                     test="matches($Work_documenttype, '^bill$') and not($is_besluit)"
                     role="fout">
	    {"code": "STOP2002", "Work-ID": "<sch:value-of select="$Work"/>", "soortWork": "<sch:value-of select="$soortWork"/>", "melding": "FRBRWork '<sch:value-of select="$Work"/>' begint met '/akn/nl/bill/' maar soortwork'<sch:value-of select="$soortWork"/>' is niet gelijk aan '/join/id/stop/work_003'(besluit).", "ernst": "fout"},</sch:report>
         <sch:p>Als FRBRWork begint met "/akn/nl/act/" dan moet het soortwork "/join/id/stop/work_019"
        (regeling), of "/join/id/stop/work_006"  (geconsolideerde regeling), of 
        "/join/id/stop/work_021" (tijdelijk regelingdeel), of  "/join/id/stop/work_022"
        (consolidatie van tijdelijk regelingdeel) zijn.</sch:p>
         <sch:report id="STOP2003"
                     test="matches($Work_documenttype, '^act$') and not($is_regeling)"
                     role="fout">
	    {"code": "STOP2003", "Work-ID": "<sch:value-of select="$Work"/>", "soortWork": "<sch:value-of select="$soortWork"/>", "melding": "FRBRWork '<sch:value-of select="$Work"/>' begint met '/akn/nl/act/' maar soortwork <sch:value-of select="$soortWork"/>' is niet gelijk aan '/join/id/stop/work_019'(regeling), '/join/id/stop/work_006'(geconsolideerde regeling), '/join/id/stop/work_021'(tijdelijk regelingdeel) of '/join/id/stop/work_019'(consolidatie van tijdelijk regelingdeel).", "ernst": "fout"},</sch:report>
         <sch:p>als FRBRWork begint met "/akn/nl/doc/" dan moet soortwork "/join/id/stop/work_018"
        (rectificatie) of "/join/id/stop/work_023" (kennisgeving) zijn.</sch:p>
         <sch:report id="STOP2052"
                     test="matches($Work_documenttype, '^doc$') and not($is_rectificatie or $is_kennisgeving)"
                     role="fout">
	    {"code": "STOP2052", "Work-ID": "<sch:value-of select="$Work"/>", "soortWork": "<sch:value-of select="$soortWork"/>", "melding": "FRBRWork '<sch:value-of select="$Work"/>' begint met '/akn/nl/doc/' maar soortwork <sch:value-of select="$soortWork"/>' is niet gelijk aan '/join/id/stop/work_018'(rectificatie) of '/join/id/stop/work_023'(kennisgeving).", "ernst": "fout"},</sch:report>
         <sch:p>als FRBRWork begint met "/join/id" dan moet soortwork "/join/id/stop/work_010"
        (informatieobject) of "/join/id/stop/work_005" (geconsolideerd informatieobject)
        zijn.</sch:p>
         <sch:report id="STOP2024"
                     test="(matches($Work_objecttype, '^id$')) and not($is_informatieobject or $is_cons_informatieobject)"
                     role="fout">
	    {"code": "STOP2024", "Work-ID": "<sch:value-of select="$Work"/>", "soortWork": "<sch:value-of select="$soortWork"/>", "melding": "FRBRWork '<sch:value-of select="$Work"/>' begint met '/join/id' maar soortwork <sch:value-of select="$soortWork"/>' is niet gelijk aan '/join/id/stop/work_010'(informatieobject) of '/join/id/stop/work_005'(geconsolideerd informatieobject).", "ernst": "fout"},</sch:report>
         <sch:p>Een componentverwijzing in akn of join moet beginnen met een '!'</sch:p>
         <sch:assert id="STOP1071"
                     test="empty($componentdeel) or matches($componentdeel, '^![A-z0-9_/-/=]+$')"
                     role="fout">
        {"code": "STOP1071", "deel": "<sch:value-of select="$componentdeel"/>", "melding": "Het componentdeel <sch:value-of select="$componentdeel"/> van de identifier begint niet met een '!'. Corrigeer de identifier.", "ernst": "fout"},</sch:assert>
         <sch:p>Het laatste deel van een akn of join voor een optionele componentverwijzing mag geen '!' bevatten</sch:p>
         <sch:report id="STOP1072"
                     test="contains($Expression_restdeel_deel2, '!')"
                     role="fout">
        {"code": "STOP1072", "deel": "<sch:value-of select="$Expression_restdeel_deel2"/>", "melding": "Het laatste deel van een akn of join '<sch:value-of select="$Expression_restdeel_deel2"/>' voor een optionele componentverwijzing mag geen '!' bevatten. Zet een '/' voor de '!' of verwijder de '!'.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_058">
      <sch:rule context="data:ExpressionIdentificatie[data:soortWork = '/join/id/stop/work_021']">
         <sch:p>De identificatie van een tijdelijk regelingdeel (data:soortWork =
        '/join/id/stop/work_021') MOET aangeven waarvan het een tijdelijk deel is (heeft
        data:isTijdelijkDeelVan).</sch:p>
         <sch:assert id="STOP2058" test="child::data:isTijdelijkDeelVan" role="fout">
	    {"code": "STOP2058", "Work-ID": "<sch:value-of select="data:FRBRWork"/>", "melding": "De ExpressionIdentificatie('<sch:value-of select="data:FRBRWork"/>') is van een tijdelijk regelingdeel (data:soortWork = '/join/id/stop/work_021') maar deze geeft niet aan van welke regeling het een tijdelijk deel is. Voeg data:isTijdelijkDeelVan toe.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_006">
      <sch:title>Tijdelijk regelingdeel</sch:title>
      <sch:rule context="data:isTijdelijkDeelVan">
         <sch:let name="soortWorkTijdelijkdeel"
                  value="parent::data:ExpressionIdentificatie/data:soortWork/string()"/>
         <sch:let name="workTijdelijkdeel"
                  value="parent::data:ExpressionIdentificatie/data:FRBRWork/string()"/>
         <sch:let name="workTijdelijkdeel_reeks"
                  value="tokenize($workTijdelijkdeel, '/')"/>
         <sch:let name="workTijdelijkDeel_documenttype"
                  value="$workTijdelijkdeel_reeks[4]"/>
         <sch:let name="soortWorkVanRegeling"
                  value="data:WorkIdentificatie/data:soortWork/string()"/>
         <sch:let name="workVanRegeling"
                  value="data:WorkIdentificatie/data:FRBRWork/string()"/>
         <sch:let name="workVanRegeling_reeks" value="tokenize($workVanRegeling, '/')"/>
         <sch:let name="workVanRegeling_documenttype" value="$workVanRegeling_reeks[4]"/>
         <sch:let name="is_tijdelijkregelingdeel"
                  value="$soortWorkTijdelijkdeel = '/join/id/stop/work_021'"/>
         <sch:let name="is_regeling"
                  value="$soortWorkVanRegeling = '/join/id/stop/work_019'"/>
         <sch:p>De identificatie van een tijdelijk regelingdeel (data:ExpressionIdentificatie bevat
        data:isTijdelijkDeelVan) MOET als soortWork '/join/id/stop/work_021' (tijdelijk
        regelingdeel) hebben.</sch:p>
         <sch:assert id="STOP2004" test="$is_tijdelijkregelingdeel" role="fout">
        {"code": "STOP2004", "soortWork": "<sch:value-of select="$soortWorkTijdelijkdeel"/>", "melding": "De ExpressionIdentificatie bevat data:isTijdelijkDeelVan, maar data:soortWork('<sch:value-of select="$soortWorkTijdelijkdeel"/>') is niet gelijk aan '/join/id/stop/work_021'(tijdelijk regelingdeel). Pas soortWork aan.", "ernst": "fout"},</sch:assert>
         <sch:p>De identificatie van een tijdelijk regelingdeel (ExpressionIdentificatie bevat
        data:isTijdelijkDeelVan) MOET tijdelijk deel zijn van een regeling met soortWork
        '/join/id/stop/work_019' (regeling).</sch:p>
         <sch:assert id="STOP2057" test="$is_regeling" role="fout">
        {"code": "STOP2057", "soortWork": "<sch:value-of select="$soortWorkVanRegeling"/>", "melding": "De ExpressionIdentificatie bevat data:isTijdelijkDeelVan, maar het soortWork('<sch:value-of select="$soortWorkVanRegeling"/>') van de regeling waar deze regeling een tijdelijk deel van is, is niet gelijk aan '/join/id/stop/work_019' (regeling). Pas soortWork aan.", "ernst": "fout"},</sch:assert>
         <sch:p>ALS het soortwork van het Work waar een tijdelijk regelingdeel toe behoort 
        '/join/id/stop/work_019' (regeling) is, 
        DAN MOET het derde deel van het FRBRWork '/act/' zijn.</sch:p>
         <sch:assert id="STOP2063"
                     test="$workVanRegeling_documenttype = 'act'"
                     role="fout">
      {"code": "STOP2063", "Work-id": "<sch:value-of select="$workVanRegeling"/>", "melding": "De ExpressionIdentificatie bevat een isTijdelijkdeelVan:WorkIdentificatie:soortWork met '/join/id/stop/work_019' (regeling), maar het derde deel van isTijdelijkdeelVan:WorkIdentificatie:FRBRWork('<sch:value-of select="$workVanRegeling"/>') is niet gelijk aan '/act/'. Pas FRBRWork aan.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern>
      <sch:rule context="cons:doel | data:doel">
         <sch:let name="hetDoel"
                  value="substring-after(normalize-space(./string()), '/')"/>
         <sch:let name="doelDelen" value="tokenize($hetDoel, '/')"/>
         <sch:let name="resultaat">
            <xsl:if test="not($doelDelen[1] = 'join')">'<xsl:value-of select="$doelDelen[1]"/>' moet
          zijn 'join', </xsl:if>
            <xsl:if test="not($doelDelen[2] = 'id')">'<xsl:value-of select="$doelDelen[2]"/>' moet zijn
          'id', </xsl:if>
            <xsl:if test="not($doelDelen[3] = 'proces')">'<xsl:value-of select="$doelDelen[3]"/>' moet
          zijn 'proces', </xsl:if>
            <xsl:if test="not(matches($doelDelen[4], '^(mnre\d{4}|mn\d{3}|gm\d{4}|ws\d{4}|pv\d{2})'))">'<xsl:value-of select="$doelDelen[4]"/>' is geen geldige code, </xsl:if>
            <xsl:if test="not(($doelDelen[5] castable as xs:date) or ($doelDelen[5] castable as xs:gYear)) or not((string-length($doelDelen[5]) = 4) or (string-length($doelDelen[5]) = 10))">'<xsl:value-of select="$doelDelen[5]"/>' is geen geldige datum, </xsl:if>
            <xsl:if test="not(matches($doelDelen[6], '^[a-zA-Z0-9][a-zA-Z0-9_-]*$'))">'<xsl:value-of select="$doelDelen[6]"/>' is geen correcte naam voor een doel, </xsl:if>
         </sch:let>
         <sch:assert id="STOP1038" test="$resultaat = ''" role="fout">{"code": "STOP1038", "resultaat": "<sch:value-of select="normalize-space($resultaat)"/>", "melding": "De identificatie voor doel is niet correct: <sch:value-of select="normalize-space($resultaat)"/> corrigeer de identificatie voor doel.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
