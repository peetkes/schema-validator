<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:data="https://standaarden.overheid.nl/stop/imop/data/"
            xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:ns prefix="data" uri="https://standaarden.overheid.nl/stop/imop/data/"/>
   <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
   <sch:p>Versie 1.3.0</sch:p>
   <sch:p>Schematron voor aanvullende validatie voor consolidatie-informatie</sch:p>
   <sch:pattern id="sch_data_012" see="data:BeoogdeRegeling">
      <sch:title>data:instrumentVersie moet expressionID (AKN/act) zijn</sch:title>
      <sch:rule context="data:BeoogdeRegeling">
         <sch:p>data:instrumentVersie moet expressionID (AKN/act) zijn</sch:p>
         <sch:assert id="STOP1026"
                     test="matches(./data:instrumentVersie/string(), '^/akn/(nl|aw|cw|sx)/act')"
                     role="fout">
        {"code": "STOP1026", "ID": "<sch:value-of select="./data:instrumentVersie/string()"/>", "melding": "De waarde van instrumentVersie <sch:value-of select="./data:instrumentVersie/string()"/> in BeoogdeRegeling MOET een expressionID (/akn/nl/act) zijn", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_013" see="data:BeoogdInformatieobject">
      <sch:title>data:instrumentVersie moet JOIN/regdata zijn</sch:title>
      <sch:rule context="data:BeoogdInformatieobject">
         <sch:p>data:instrumentVersie moet JOIN/regdata zijn</sch:p>
         <sch:assert id="STOP1027"
                     test="matches(./data:instrumentVersie/string(), '^/join/id/regdata/') or matches(./data:instrumentVersie/string(), '^/join/id/pubdata/')"
                     role="fout">
        {"code": "STOP1027", "ID": "<sch:value-of select="./data:instrumentVersie/string()"/>", "melding": "De waarde van instrumentVersie in BeoogdInformatieobject <sch:value-of select="./data:instrumentVersie/string()"/> MOET een /join/id/regdata zijn", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_014" see="data:BeoogdInformatieobject">
      <sch:title>data:Intrekking/data:instrument moet een Work-Id ('/AKN/act/...' of
      '/join/id/regdata/...') hebben</sch:title>
      <sch:rule context="data:Intrekking">
         <sch:p>Het instrument binnen een Intrekking moet een akn of join identificatie hebben
        ('/AKN/act/[...]' of '/join/id/regdata/[...]')</sch:p>
         <sch:assert id="STOP1028"
                     test="matches(./data:instrument/string(), '^/akn/(nl|aw|cw|sx)/act|^/join/id/regdata/')"
                     role="fout">
        {"code": "STOP1028", "ID": "<sch:value-of select="./data:instrument/string()"/>", "melding": "Het instrument binnen een Intrekking <sch:value-of select="./data:instrument/string()"/> heeft geen juiste identificatie ('/akn/nl/act/[...]' of '/join/id/regdata/[...]'). Pas de identificatie aan.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_015" see="data:doel data:Tijdstempel">
      <sch:title>Een doel kan maar 1 datum inwerking hebben</sch:title>
      <sch:rule context="data:Tijdstempels">
         <sch:p>Een doel kan maar 1 datum inwerking hebben</sch:p>
         <sch:assert id="STOP1029"
                     test="count(./data:Tijdstempel/data:doel[(../data:soortTijdstempel = 'juridischWerkendVanaf' or ../data:soortTijdstempel = 'geldigVanaf')]) = count(distinct-values(./data:Tijdstempel/data:doel[(../data:soortTijdstempel = 'juridischWerkendVanaf' or ../data:soortTijdstempel = 'geldigVanaf')]))"
                     role="fout">
        {"code": "STOP1029", "melding": "Het gegeven doel heeft meer dan één datum inwerkingtreding. Een doel kan maar 1 datum inwerking hebben", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_data_016" see="data:BeoogdeRegelgeving">
      <sch:rule context="data:gemaaktOpBasisVan">
         <sch:p>De doelen van de versies in data:gemaaktOpBasisVan MOGEN NIET gelijk zijn</sch:p>
         <sch:let name="Doelen">
            <xsl:for-each select="data:*/data:doel">
               <doel>
                  <xsl:value-of select="./string()"/>
               </doel>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="STOP2065"
                     test="count($Doelen/doel) = count(distinct-values($Doelen/doel))"
                     role="fout">
        {"code": "STOP2065", "instrumentVersie": "<sch:value-of select="../data:instrumentVersie/string()"/>", "melding": "De doelen van de versies in data:gemaaktOpBasisVan van instrumentversie <sch:value-of select="../data:instrumentVersie/string()"/> zijn niet uniek. Dit is niet toegestaan. Zorg ervoor dat elke Basisversie, VervlochtenVersie en OntvlochtenVersie een uniek doel heeft.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern>
      <sch:rule context="data:VervlochtenVersie | data:OntvlochtenVersie">
         <sch:p>De doelen van de Ver- en OntvlochtenVersies MOGEN NIET overeenkomen met het doel/de
        doelen van de BeoogdeRegeling of het BeoogdInformatieobject</sch:p>
         <sch:let name="doel" value="data:doel"/>
         <sch:report id="STOP2066" test="../../data:doelen[data:doel=$doel]" role="fout">
        {"code": "STOP2066", "doel": "<sch:value-of select="data:doel/string()"/>", "instrumentVersie": "<sch:value-of select="../../data:instrumentVersie/string()"/>", "melding": "Het doel <sch:value-of select="data:doel/string()"/> van de Ver- of OntvlochtenVersie in data:gemaaktOpBasisVan van instrumentversie <sch:value-of select="../../data:instrumentVersie/string()"/> komt ook voor als doel van de BeoogdeRegeling/BeoogdInformatieobject. Dit is niet toegestaan. Zorg ervoor dat het doel van de Ver- of OntvlochtenVersie verschilt van het doel van de BeoogdeRegeling/BeoogdInformatieobject.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
</sch:schema>
