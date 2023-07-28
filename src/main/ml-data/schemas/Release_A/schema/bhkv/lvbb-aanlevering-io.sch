<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:data="https://standaarden.overheid.nl/stop/imop/data/"
            xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:ns prefix="data" uri="https://standaarden.overheid.nl/stop/imop/data/"/>
   <sch:ns prefix="tekst" uri="https://standaarden.overheid.nl/stop/imop/tekst/"/>
   <sch:ns prefix="gio" uri="https://standaarden.overheid.nl/stop/imop/gio/"/>
   <sch:ns prefix="se" uri="http://www.opengis.net/se"/>
   <sch:ns prefix="lvbba"
           uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/"/>
   <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
   <sch:p>Versie 1.2.0</sch:p>
   <sch:p>Schematron voor aanvullende validaties voor lvbba</sch:p>
   <!--  -->
   <sch:pattern id="sch_lvbba_BHKV1014" see="lvbba:InformatieObjectVersie">
      <sch:title>Informatieobject - aanleveren GIO</sch:title>
      <sch:rule context="lvbba:InformatieObjectVersie">
         <sch:let name="Expression-ID"
                  value="data:ExpressionIdentificatie/data:FRBRExpression"/>
         <sch:assert id="BHKV1014"
                     test="count(data:InformatieObjectVersieMetadata/data:heeftBestanden/data:heeftBestand) = 1"
                     role="fout">
        {"code": "BHKV1014", "Expression-ID": "<sch:value-of select="$Expression-ID"/>", "melding": "Element data:heeftBestanden van <sch:value-of select="$Expression-ID"/> moet bestaan uit één bestand. In de aanlevering zitten meer of minder dan één bestand. Dit is niet toegestaan, lever precies één bestand aan.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!--  -->
   <sch:pattern id="sch_lvbba_023" see="data:heeftGeboorteregeling">
      <sch:title>heeftGeboorteregeling met juiste soortWork en formaatInformatieobject</sch:title>
      <sch:rule context="lvbba:AanleveringInformatieObject//lvbba:InformatieObjectVersie[normalize-space(//data:soortWork) = '/join/id/stop/work_010'][normalize-space(//data:formaatInformatieobject) = '/join/id/stop/gio_002']">
         <sch:p>heeftGeboorteregeling MOET aanwezig zijn INDIEN saartWork=work_010 èn
        formaatinformatieobject=gio_002</sch:p>
         <sch:assert id="BHKV1015" test="//data:heeftGeboorteregeling" role="fout">{"code": "BHKV1015", "id": "<sch:value-of select="//data:FRBRExpression"/>", "melding": "heeftGeboorteregeling voor <sch:value-of select="//data:FRBRExpression"/> is niet aanwezig, is verplicht wanneer soortWork=/join/id/stop/work_010 èn formaatinformatieobject=/join/id/stop/informatieobject/gio_002. Voeg de AKN-identificatie voor heeftGeboorteregeling toe.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!--  -->
   <sch:pattern id="sch_lvbba_024">
      <sch:title>Informatieobject van het juiste type</sch:title>
      <sch:rule context="lvbba:AanleveringInformatieObject//lvbba:InformatieObjectVersie//data:ExpressionIdentificatie">
         <sch:p>De identificatie van een InformatieObject moet als soort werk '/join/id/stop/work_010'
        zijn</sch:p>
         <sch:assert id="BHKV1016"
                     test="normalize-space(data:soortWork) = '/join/id/stop/work_010'"
                     role="fout">{"code": "BHKV1016", "work": "<sch:value-of select="data:soortWork"/>", "id": "<sch:value-of select="data:FRBRExpression"/>", "melding": "Het aangeleverde informatieobject <sch:value-of select="data:FRBRExpression"/> heeft als soortWork <sch:value-of select="data:soortWork"/> dit moet '/join/id/stop/work_010' zijn.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!--  -->
   <sch:pattern id="sch_lvbba_025">
      <sch:title>Officieletitel gelijk aan FRBRWork</sch:title>
      <sch:rule context="lvbba:InformatieObjectVersie/data:InformatieObjectMetadata/data:officieleTitel">
         <sch:let name="titel" value="normalize-space(.)"/>
         <sch:let name="work"
                  value="normalize-space(ancestor::lvbba:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRWork)"/>
         <sch:p>De officiele titel van een informatieobject moet gelijk zijn aan het FRBRWork</sch:p>
         <sch:assert id="BHKV1017" test="$work = $titel" role="fout">
      {"code": "BHKV1017", "work": "<sch:value-of select="$work"/>", "titel": "<sch:value-of select="$titel"/>", "melding": "De officiele titel <sch:value-of select="$titel"/> komt niet overeen met de identifier FRBRWork <sch:value-of select="$work"/>", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!--  -->
   <sch:pattern id="sch_lvbba_026">
      <sch:title>De collectie gebruikt in de AKN identifier van een informatieobject MOET overeenkomen met zijn data:publicatieinstructie</sch:title>
      <sch:rule context="lvbba:InformatieObjectVersie/data:InformatieObjectMetadata/data:publicatieinstructie">
         <sch:let name="work"
                  value="normalize-space(ancestor::lvbba:InformatieObjectVersie/data:ExpressionIdentificatie/data:FRBRWork)"/>
         <sch:let name="Work_reeks" value="tokenize($work, '/')"/>
         <sch:let name="Work_collectie" value="$Work_reeks[4]"/>
         <sch:p>publicatieinstructie moet passen bij AKN identifier veld collectie</sch:p>
         <sch:assert id="BHKV1018"
                     test="(((./string()='TeConsolideren') and ($Work_collectie='regdata')) or                                                  ((./string()='AlleenBekendTeMaken') and ($Work_collectie='pubdata')) or                 ((./string()='Informatief') and ($Work_collectie='infodata')))"
                     role="fout">
      {"code": "BHKV1018", "Work-ID": "<sch:value-of select="$work"/>", "substring": "<sch:value-of select="./string()"/>", "melding": "De collectie in de FRBRWork identifier <sch:value-of select="$work"/> komt niet overeen met de publicatieinstructie <sch:value-of select="./string()"/>", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_027">
      <sch:title>De module se:FeatureTypeStyle MAG ALLEEN bij een Geoinformatieobject
      aangeleverd worden.</sch:title>
      <sch:rule context="lvbba:InformatieObjectVersie/se:FeatureTypeStyle[preceding-sibling::data:InformatieObjectMetadata]">
         <sch:let name="formaat"
                  value="preceding-sibling::data:InformatieObjectMetadata/data:formaatInformatieobject/string()"/>
         <sch:assert id="BHKV1064"
                     test="$formaat = '/join/id/stop/informatieobject/gio_002'"
                     role="fout">
      {"code": "BHKV1064", "Expressie": "<sch:value-of select="normalize-space(preceding-sibling::data:ExpressionIdentificatie/data:FRBRExpression)"/>", "Module": "<sch:value-of select="node-name(.)"/>", "formaat": "<sch:value-of select="$formaat"/>", "melding": "De aanlevering van <sch:value-of select="normalize-space(preceding-sibling::data:ExpressionIdentificatie/data:FRBRExpression)"/> mag de module <sch:value-of select="node-name(.)"/> niet bevatten omdat het formaatInformatieobject(<sch:value-of select="$formaat"/>) niet \"/join/id/stop/informatieobject/gio_002\"(GIO) is. Verwijder de module of wijzig het formaat.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_028">
      <sch:title>De module gio:JuridischeBorgingVan MAG ALLEEN bij een Geoinformatieobject
      aangeleverd worden.</sch:title>
      <sch:rule context="lvbba:InformatieObjectVersie/gio:JuridischeBorgingVan[preceding-sibling::data:InformatieObjectMetadata]">
         <sch:let name="formaat"
                  value="preceding-sibling::data:InformatieObjectMetadata/data:formaatInformatieobject/string()"/>
         <sch:assert id="BHKV1065"
                     test="$formaat = '/join/id/stop/informatieobject/gio_002'"
                     role="fout">
      {"code": "BHKV1065", "Expressie": "<sch:value-of select="normalize-space(preceding-sibling::data:ExpressionIdentificatie/data:FRBRExpression)"/>", "Module": "<sch:value-of select="node-name(.)"/>", "formaat": "<sch:value-of select="$formaat"/>", "melding": "De aanlevering van <sch:value-of select="normalize-space(preceding-sibling::data:ExpressionIdentificatie/data:FRBRExpression)"/> mag de module <sch:value-of select="node-name(.)"/> niet bevatten omdat het formaatInformatieobject(<sch:value-of select="$formaat"/>) niet \"/join/id/stop/informatieobject/gio_002\"(GIO) is. Verwijder de module of wijzig het formaat.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
