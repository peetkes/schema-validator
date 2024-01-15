<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:tekst="https://standaarden.overheid.nl/stop/imop/tekst/"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:ns prefix="tekst" uri="https://standaarden.overheid.nl/stop/imop/tekst/"/>
   <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
   <sch:p>Versie 1.3.0</sch:p>
   <sch:p>Schematron voor aanvullende validatie voor imop-tekst.xsd</sch:p>
   <sch:pattern id="sch_tekst_001">
      <sch:title>Lijst - Nummering lijstitems</sch:title>
      <sch:rule context="tekst:Lijst[@type = 'ongemarkeerd']">
         <sch:assert id="STOP0001" test="count(tekst:Li/tekst:LiNummer) = 0" role="fout"> {"code": "STOP0001", "eId": "<sch:value-of select="@eId"/>", "melding": "De Lijst met eId <sch:value-of select="@eId"/> van type 'ongemarkeerd' heeft LiNummer-elementen met een nummering of opsommingstekens, dit is niet toegestaan. Pas het type van de lijst aan of verwijder de LiNummer-elementen.", "ernst": "fout"},</sch:assert>
      </sch:rule>
      <sch:rule context="tekst:Lijst[@type = 'expliciet']">
         <sch:assert id="STOP0002"
                     test="count(tekst:Li[tekst:LiNummer]) = count(tekst:Li)"
                     role="fout"> {"code": "STOP0002", "eId": "<sch:value-of select="@eId"/>", "melding": "De Lijst met eId <sch:value-of select="@eId"/> van type 'expliciet' heeft geen LiNummer elementen met nummering of opsommingstekens, het gebruik van LiNummer is verplicht. Pas het type van de lijst aan of voeg LiNummer's met nummering of opsommingstekens toe aan de lijst-items", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_022">
      <sch:title>Alinea - Bevat content</sch:title>
      <sch:rule context="tekst:Al">
         <sch:report id="STOP0005"
                     test="normalize-space(./string()) = '' and not(tekst:InlineTekstAfbeelding | tekst:Nootref)"
                     role="fout"> {"code": "STOP0005", "element": "<sch:value-of select="ancestor::tekst:*[@eId][1]/local-name()"/>", "eId": "<sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/>", "melding": "De alinea voor element <sch:value-of select="ancestor::tekst:*[@eId][1]/local-name()"/> met id <sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/> bevat geen tekst. Verwijder de lege alinea", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_027">
      <sch:title>Kop - Bevat content</sch:title>
      <sch:rule context="tekst:Kop">
         <sch:report id="STOP0006" test="normalize-space(./string()) = ''" role="fout"> {"code": "STOP0006", "element": "<sch:value-of select="ancestor::tekst:*[@eId][1]/local-name()"/>", "eId": "<sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/>", "melding": "De kop voor element <sch:value-of select="ancestor::tekst:*[@eId][1]/local-name()"/> met id <sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/> bevat geen tekst. Corrigeer de kop of verplaats de inhoud naar een ander element", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_003">
      <sch:title>Tabel - Referenties naar een noot</sch:title>
      <sch:rule context="tekst:table//tekst:Nootref">
         <sch:let name="nootID" value="@refid"/>
         <sch:assert id="STOP0008"
                     test="ancestor::tekst:table//tekst:Noot[@id = $nootID]"
                     role="fout"> {"code": "STOP0008", "ref": "<sch:value-of select="@refid"/>", "eId": "<sch:value-of select="ancestor::tekst:table/@eId"/>", "melding": "De referentie naar de noot met id <sch:value-of select="@refid"/> verwijst niet naar een noot in dezelfde tabel <sch:value-of select="ancestor::tekst:table/@eId"/>. Verplaats de noot waarnaar verwezen wordt naar de tabel of vervang de referentie in de tabel voor de noot waarnaar verwezen wordt", "ernst": "fout"},</sch:assert>
      </sch:rule>
      <sch:rule context="tekst:Nootref">
         <sch:let name="nootID" value="@refid"/>
         <sch:assert id="STOP0007" test="ancestor::tekst:table" role="fout"> {"code": "STOP0007", "ref": "<sch:value-of select="@refid"/>", "melding": "De referentie naar de noot met id <sch:value-of select="@refid"/> staat niet in een tabel. Vervang de referentie naar de noot voor de noot waarnaar verwezen wordt", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_004">
      <sch:title>Lijst - plaatsing tabel in een lijst</sch:title>
      <sch:rule context="tekst:Li[tekst:table]">
         <sch:report id="STOP0009"
                     test="self::tekst:Li/tekst:table and not(ancestor::tekst:Instructie)"
                     role="waarschuwing"> {"code": "STOP0009", "eId": "<sch:value-of select="@eId"/>", "melding": "Het lijst-item <sch:value-of select="@eId"/> bevat een tabel, onderzoek of de tabel buiten de lijst kan worden geplaatst, eventueel door de lijst in delen op te splitsen", "ernst": "waarschuwing"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_032">
      <sch:title>Illustratie - attributen kleur en schaal worden niet ondersteund</sch:title>
      <sch:rule context="tekst:Illustratie | tekst:InlineTekstAfbeelding">
         <sch:report id="STOP0045" test="@schaal" role="waarschuwing"> {"code": "STOP0045", "ouder": "<sch:value-of select="local-name(ancestor::*[@eId][1])"/>", "eId": "<sch:value-of select="ancestor::*[@eId][1]/@eId"/>", "melding": "De Illustratie binnen <sch:value-of select="local-name(ancestor::*[@eId][1])"/> met eId <sch:value-of select="ancestor::*[@eId][1]/@eId"/> heeft een waarde voor attribuut @schaal. Dit attribuut wordt genegeerd in de publicatie van documenten volgens STOP 1.3.0. In plaats daarvan wordt het attribuut @dpi gebruikt voor de berekening van de afbeeldingsgrootte. Verwijder het attribuut @schaal.", "ernst": "waarschuwing"},</sch:report>
         <sch:report id="STOP0046" test="@kleur" role="waarschuwing"> {"code": "STOP0046", "ouder": "<sch:value-of select="local-name(ancestor::*[@eId][1])"/>", "eId": "<sch:value-of select="ancestor::*[@eId][1]/@eId"/>", "melding": "De Illustratie binnen <sch:value-of select="local-name(ancestor::*[@eId][1])"/> met eId <sch:value-of select="ancestor::*[@eId][1]/@eId"/> heeft een waarde voor attribuut @kleur. Dit attribuut wordt genegeerd in de publicatie van STOP 1.3.0. Verwijder het attribuut @kleur.", "ernst": "waarschuwing"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <!--
    INTERNE REFERENTIES HEBBEN CORRECTE VERWIJZINGEN
  -->
   <sch:pattern id="sch_tekst_006">
      <sch:title>Referentie intern - correcte verwijzing</sch:title>
      <sch:rule context="tekst:IntRef[not(ancestor::tekst:RegelingMutatie | ancestor::tekst:BesluitMutatie)]">
         <sch:let name="doelwit">
            <xsl:choose>
               <xsl:when test="starts-with(@ref, '!')">
                  <xsl:value-of select="substring-after(@ref, '#')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="@ref"/>
               </xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="component">
            <xsl:choose>
               <xsl:when test="starts-with(@ref, '!')">
                  <xsl:value-of select="substring-before(translate(@ref, '!', ''), '#')"/>
               </xsl:when>
               <xsl:when test="ancestor::tekst:*[@componentnaam]">
                  <xsl:value-of select="ancestor::tekst:*[@componentnaam]/@componentnaam"/>
               </xsl:when>
               <xsl:otherwise>[is_geen_component]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="scopeNaam">
            <xsl:choose>
               <xsl:when test="@scope">
                  <xsl:value-of select="@scope"/>
               </xsl:when>
               <xsl:otherwise>[geen-scope]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="localName">
            <xsl:choose>
               <xsl:when test="//tekst:*[@eId = $doelwit and ($component = '[is_geen_component]' or ancestor::tekst:*[@componentnaam][1]/@componentnaam = $component) and not(ancestor::tekst:RegelingMutatie | ancestor::tekst:BesluitMutatie)]">
                  <xsl:choose>
                     <xsl:when test="$component = '[is_geen_component]'">
                        <xsl:value-of select="//tekst:*[@eId = $doelwit][not(ancestor::tekst:*[@componentnaam])]/local-name()"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//tekst:*[@eId = $doelwit][ancestor::tekst:*[@componentnaam][1]/@componentnaam = $component]/local-name()"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </sch:let>
         <sch:assert id="STOP0010"
                     test="//tekst:*[@eId = $doelwit and ($component = '[is_geen_component]' or ancestor::tekst:*[@componentnaam][1]/@componentnaam = $component) and not(ancestor::tekst:RegelingMutatie | ancestor::tekst:BesluitMutatie)]"
                     role="fout"> 
        {"code": "STOP0010", "ref": "<sch:value-of select="$doelwit"/>", "melding": "De waarde van @ref van element tekst:IntRef met waarde <sch:value-of select="$doelwit"/> komt niet voor als eId van een tekst-element in (de mutatie van) de tekst van dezelfde expression als de IntRef. Controleer de referentie, corrigeer of de referentie of de identificatie van het element waarnaar wordt verwezen.", "ernst": "fout"},</sch:assert>
         <sch:assert id="STOP0053"
                     test="$scopeNaam = '[geen-scope]' or $scopeNaam = $localName"
                     role="fout">
      {"code": "STOP0053", "ref": "<sch:value-of select="$doelwit"/>", "scope": "<sch:value-of select="$scopeNaam"/>", "local": "<sch:value-of select="$localName"/>", "melding": "De scope <sch:value-of select="$scopeNaam"/> van de IntRef met <sch:value-of select="$doelwit"/> is niet gelijk aan de naam van het doelelement <sch:value-of select="$localName"/>.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_028">
      <sch:title>Referentie informatieobject - correcte verwijzing</sch:title>
      <sch:rule context="tekst:IntIoRef[not(ancestor::tekst:RegelingMutatie | ancestor::BesluitMutatie)]">
         <sch:let name="doelwit" value="@ref"/>
         <sch:assert id="STOP0011" test="//tekst:ExtIoRef[@wId = $doelwit]" role="fout"> {"code": "STOP0011", "element": "<sch:name/>", "ref": "<sch:value-of select="$doelwit"/>", "melding": "De @ref van element <sch:name/> met waarde <sch:value-of select="$doelwit"/> verwijst niet naar een wId van een ExtIoRef binnen hetzelfde bestand. Controleer de referentie, corrigeer of de referentie of de wId identificatie van het element waarnaar wordt verwezen", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_007">
      <sch:title>Referentie extern informatieobject</sch:title>
      <sch:rule context="tekst:ExtIoRef">
         <sch:let name="ref" value="normalize-space(@ref)"/>
         <sch:assert id="STOP0012" test="normalize-space(.) = $ref" role="fout"> {"code": "STOP0012", "eId": "<sch:value-of select="@eId"/>", "melding": "De JOIN-identifier van ExtIoRef <sch:value-of select="@eId"/> in de tekst is niet gelijk aan de als referentie opgenomen JOIN-identificatie. Controleer de gebruikte JOIN-identicatie en plaats de juiste verwijzing als zowel de @ref als de tekst van het element ExtIoRef", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_008">
      <sch:title>Identificatie - correct gebruik wId, eId </sch:title>
      <sch:rule context="//*[@eId]">
         <sch:let name="doelwitE" value="@eId"/>
         <sch:let name="doelwitW" value="@wId"/>
         <sch:report id="STOP0013" test="ends-with($doelwitE, '.')" role="fout"> {"code": "STOP0013", "eId": "<sch:value-of select="@eId"/>", "element": "<sch:name/>", "melding": "Het attribuut @eId of een deel van de eId <sch:value-of select="@eId"/> van element <sch:name/> eindigt op een '.', dit is niet toegestaan. Verwijder de laatste punt(en) '.' voor deze eId", "ernst": "fout"},</sch:report>
         <sch:report id="STOP0043" test="contains($doelwitE, '.__')" role="fout"> {"code": "STOP0043", "eId": "<sch:value-of select="@eId"/>", "element": "<sch:name/>", "melding": "Het attribuut @eId of een deel van de eId <sch:value-of select="@eId"/> van element <sch:name/> eindigt op '.__', dit is niet toegestaan. Verwijder deze punt '.' binnen deze eId", "ernst": "fout"},</sch:report>
         <sch:report id="STOP0014" test="ends-with($doelwitW, '.')" role="fout"> {"code": "STOP0014", "wId": "<sch:value-of select="@wId"/>", "element": "<sch:name/>", "melding": "Het attribuut @wId <sch:value-of select="@wId"/> van element <sch:name/> eindigt op een '.', dit is niet toegestaan. Verwijder de laatste punt '.' van deze wId", "ernst": "fout"},</sch:report>
         <sch:report id="STOP0044" test="contains($doelwitW, '.__')" role="fout"> {"code": "STOP0044", "wId": "<sch:value-of select="@wId"/>", "element": "<sch:name/>", "melding": "Het attribuut @wId <sch:value-of select="@wId"/> van element <sch:name/> eindigt op een '.__', dit is niet toegestaan. Verwijder deze punt '.' binnen deze wId", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_023">
      <sch:title>RegelingTijdelijkdeel - WijzigArtikel niet toegestaan</sch:title>
      <sch:rule context="tekst:RegelingTijdelijkdeel//tekst:WijzigArtikel">
         <sch:report id="STOP0015" test="self::tekst:WijzigArtikel" role="fout"> {"code": "STOP0015", "eId": "<sch:value-of select="@eId"/>", "melding": "Het WijzigArtikel <sch:value-of select="@eId"/> is in een RegelingTijdelijkdeel niet toegestaan. Verwijder het WijzigArtikel of pas dit aan naar een Artikel indien dit mogelijk is", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_026">
      <sch:title>RegelingCompact - WijzigArtikel niet toegestaan</sch:title>
      <sch:rule context="tekst:RegelingCompact//tekst:WijzigArtikel">
         <sch:report id="STOP0016" test="self::tekst:WijzigArtikel" role="fout"> {"code": "STOP0016", "eId": "<sch:value-of select="@eId"/>", "melding": "Het WijzigArtikel <sch:value-of select="@eId"/> is in een RegelingCompact niet toegestaan. Verwijder het WijzigArtikel of pas dit aan naar een Artikel indien dit mogelijk is", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <!-- 
    Renvooi markering alleen toegestaan binnen een tekst:RegelingMutatie
  -->
   <sch:pattern id="sch_tekst_009"
                see="tekst:RegelingMutatie tekst:NieuweTekst     tekst:VerwijderdeTekst">
      <sch:title>Mutaties - Wijzigingen tekstueel</sch:title>
      <sch:rule context="tekst:NieuweTekst | tekst:VerwijderdeTekst">
         <sch:p>Een tekstuele mutatie ten behoeve van renvooi MAG NIET buiten een Regeling- of
        BesluitMutatie voorkomen</sch:p>
         <sch:assert id="STOP0017"
                     test="ancestor::tekst:RegelingMutatie or ancestor::tekst:BesluitMutatie"
                     role="fout"> {"code": "STOP0017", "ouder": "<sch:value-of select="local-name(parent::tekst:*)"/>", "eId": "<sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/>", "element": "<sch:name/>", "melding": "Tekstuele wijziging is niet toegestaan buiten de context van een tekst:RegelingMutatie of tekst:BesluitMutatie. element <sch:value-of select="local-name(parent::tekst:*)"/> met id \"<sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/>\" bevat een <sch:name/>. Verwijder het element <sch:name/>", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_010">
      <sch:title>Mutaties - Wijzigingen structuur</sch:title>
      <sch:rule context="tekst:*[@wijzigactie]">
         <sch:p>Een structuur wijziging MAG NIET buiten een Regeling- of BesluitMutatie
        voorkomen</sch:p>
         <sch:assert id="STOP0018"
                     test="ancestor::tekst:RegelingMutatie or ancestor::tekst:BesluitMutatie"
                     role="fout"> {"code": "STOP0018", "element": "<sch:value-of select="local-name()"/>", "eId": "<sch:value-of select="ancestor-or-self::tekst:*[@eId][1]/@eId"/>", "melding": "Een attribuut @wijzigactie is niet toegestaan op element <sch:value-of select="local-name()"/> met id \"<sch:value-of select="ancestor-or-self::tekst:*[@eId][1]/@eId"/>\" buiten de context van een tekst:RegelingMutatie of tekst:BesluitMutatie. Verwijder het attribuut @wijzigactie", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!--
    Unieke eId en wId's voor Besluiten en Regelingen
  -->
   <xsl:key match="tekst:*[@eId][not(ancestor-or-self::tekst:*[@componentnaam])][not(ancestor-or-self::tekst:WijzigInstructies)]"
            name="alleEIDs"
            use="@eId"/>
   <xsl:key match="tekst:*[@wId][not(ancestor-or-self::tekst:*[@componentnaam])][not(ancestor-or-self::tekst:WijzigInstructies)]"
            name="alleWIDs"
            use="@wId"/>
   <xsl:key match="tekst:Noot[not(ancestor-or-self::tekst:*[@componentnaam])][not(ancestor-or-self::tekst:WijzigInstructies)]"
            name="alleNootIDs"
            use="@id"/>
   <sch:pattern id="sch_tekst_011">
      <sch:title>Identificatie - Alle wId en eId buiten een AKN-component zijn uniek</sch:title>
      <sch:rule context="tekst:*[@eId][not(ancestor-or-self::tekst:*[@componentnaam])][not(ancestor-or-self::tekst:WijzigInstructies)]">
         <sch:assert id="STOP0020" test="count(key('alleEIDs', @eId)) = 1" role="fout"> {"code": "STOP0020", "eId": "<sch:value-of select="@eId"/>", "melding": "De eId '<sch:value-of select="@eId"/>' binnen het bereik is niet uniek. Controleer de opbouw van de eId en corrigeer deze", "ernst": "fout"},</sch:assert>
         <sch:assert id="STOP0021" test="count(key('alleWIDs', @wId)) = 1" role="fout"> {"code": "STOP0021", "wId": "<sch:value-of select="@wId"/>", "melding": "De wId '<sch:value-of select="@wId"/>' binnen het bereik is niet uniek. Controleer de opbouw van de wId en corrigeer deze", "ernst": "fout"},</sch:assert>
      </sch:rule>
      <sch:rule context="tekst:Noot[not(ancestor-or-self::tekst:*[@componentnaam])][not(ancestor-or-self::tekst:WijzigInstructies)]">
         <sch:assert id="STOP0068"
                     test="count(key('alleNootIDs', @id)) &lt;= 1"
                     role="fout"> {"code": "STOP0068", "id": "<sch:value-of select="@id"/>", "melding": "De id '<sch:value-of select="@id"/>' is niet uniek binnen zijn component. Controleer id en corrigeer deze", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_020">
      <sch:title>Identificatie - AKN-naamgeving voor eId en wId</sch:title>
      <sch:rule context="*[@eId]">
         <sch:let name="AKNnaam">
            <xsl:choose>
               <xsl:when test="matches(local-name(), 'Lichaam')">body</xsl:when>
               <xsl:when test="matches(local-name(), 'RegelingOpschrift')">longTitle</xsl:when>
               <xsl:when test="matches(local-name(), 'AlgemeneToelichting')">genrecital</xsl:when>
               <xsl:when test="matches(local-name(), '^ArtikelgewijzeToelichting$')">artrecital</xsl:when>
               <xsl:when test="matches(local-name(), 'Artikel|WijzigArtikel')">art</xsl:when>
               <xsl:when test="matches(local-name(), 'WijzigLid|Lid')">para</xsl:when>
               <xsl:when test="matches(local-name(), 'Divisietekst')">content</xsl:when>
               <xsl:when test="matches(local-name(), 'Divisie')">div</xsl:when>
               <xsl:when test="matches(local-name(), 'Boek')">book</xsl:when>
               <xsl:when test="matches(local-name(), 'Titel')">title</xsl:when>
               <xsl:when test="matches(local-name(), 'Deel')">part</xsl:when>
               <xsl:when test="matches(local-name(), 'Hoofdstuk')">chp</xsl:when>
               <xsl:when test="matches(local-name(), 'Afdeling')">subchp</xsl:when>
               <xsl:when test="matches(local-name(), 'Paragraaf|Subparagraaf|Subsubparagraaf')">subsec</xsl:when>
               <xsl:when test="matches(local-name(), 'WijzigBijlage|Bijlage')">cmp</xsl:when>
               <xsl:when test="matches(local-name(), 'Inhoudsopgave')">toc</xsl:when>
               <xsl:when test="matches(local-name(), 'Motivering')">acc</xsl:when>
               <xsl:when test="matches(local-name(), 'Toelichting')">recital</xsl:when>
               <xsl:when test="matches(local-name(), 'InleidendeTekst')">intro</xsl:when>
               <xsl:when test="matches(local-name(), 'Aanhef')">formula_1</xsl:when>
               <xsl:when test="matches(local-name(), 'Kadertekst')">recital</xsl:when>
               <xsl:when test="matches(local-name(), 'Sluiting')">formula_2</xsl:when>
               <xsl:when test="matches(local-name(), 'table')">table</xsl:when>
               <xsl:when test="matches(local-name(), 'Figuur')">img</xsl:when>
               <xsl:when test="matches(local-name(), 'Formule')">math</xsl:when>
               <xsl:when test="matches(local-name(), 'Citaat')">cit</xsl:when>
               <xsl:when test="matches(local-name(), 'Begrippenlijst|Lijst')">list</xsl:when>
               <xsl:when test="matches(local-name(), 'Li|Begrip')">item</xsl:when>
               <xsl:when test="matches(local-name(), 'IntIoRef|ExtIoRef')">ref</xsl:when>
               <xsl:when test="matches(local-name(), 'Rectificatietekst')">content</xsl:when>
               <xsl:otherwise>AKN-prefix-van-onbekend-element</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="mijnEID">
            <xsl:choose>
               <xsl:when test="contains(@eId, '__')">
                  <xsl:value-of select="tokenize(@eId, '__')[last()]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="@eId"/>
               </xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="mijnWID">
            <xsl:value-of select="tokenize(@wId, '__')[last()]"/>
         </sch:let>
         <sch:assert id="STOP0022" test="starts-with($mijnEID, $AKNnaam)" role="fout"> {"code": "STOP0022", "AKNdeel": "<sch:value-of select="$mijnEID"/>", "element": "<sch:name/>", "waarde": "<sch:value-of select="$AKNnaam"/>", "wId": "<sch:value-of select="@wId"/>", "melding": "De AKN-naamgeving voor eId '<sch:value-of select="$mijnEID"/>' is niet correct voor element <sch:name/> met id '<sch:value-of select="@wId"/>', Dit moet zijn: '<sch:value-of select="$AKNnaam"/>'. Pas de naamgeving voor dit element en alle onderliggende elementen aan. Controleer ook de naamgeving van de bijbehorende wId en onderliggende elementen.", "ernst": "fout"},</sch:assert>
         <sch:p>Een wId MOET voldoen aan de AKN-naamgevingsconventie</sch:p>
         <sch:assert id="STOP0023" test="starts-with($mijnWID, $AKNnaam)" role="fout"> {"code": "STOP0023", "AKNdeel": "<sch:value-of select="$mijnWID"/>", "element": "<sch:name/>", "waarde": "<sch:value-of select="$AKNnaam"/>", "wId": "<sch:value-of select="@wId"/>", "melding": "De AKN-naamgeving voor wId '<sch:value-of select="$mijnWID"/>' is niet correct voor element <sch:name/> met id '<sch:value-of select="@wId"/>', Dit moet zijn: '<sch:value-of select="$AKNnaam"/>'. Pas de naamgeving voor dit element en alle onderliggende elementen aan. Controleer ook de naamgeving van de bijbehorende eId en onderliggende elementen.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <!-- VOOR TABELLEN EEN REEKS CONTROLES OP CALS REGELS -->
   <sch:pattern id="sch_tekst_014">
      <sch:title>Tabel - minimale opbouw</sch:title>
      <sch:rule context="tekst:table/tekst:tgroup">
         <sch:assert id="STOP0029" test="number(@cols) &gt;= 2" role="waarschuwing"> {"code": "STOP0029", "eId": "<sch:value-of select="parent::tekst:table/@eId"/>", "melding": "De tabel met <sch:value-of select="parent::tekst:table/@eId"/> heeft slechts 1 kolom, dit is niet toegestaan. Pas de tabel aan, of plaats de inhoud van de tabel naar bijvoorbeeld een element Kadertekst", "ernst": "waarschuwing"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_016">
      <sch:title>Tabel - positie en identificatie van een tabelcel</sch:title>
      <sch:rule context="tekst:entry[@namest and @colname]">
         <sch:let name="start" value="@namest"/>
         <sch:let name="col" value="@colname"/>
         <sch:p>Bij horizontale overspanning MOET de eerste cel ook de start van de overspanning
        zijn</sch:p>
         <sch:assert id="STOP0033" test="$col = $start" role="fout"> {"code": "STOP0033", "naam": "<sch:value-of select="@namest"/>", "nummer": "<sch:value-of select="count(parent::tekst:row/preceding-sibling::tekst:row) + 1"/>", "ouder": "<sch:value-of select="local-name(ancestor::tekst:thead | ancestor::tekst:tbody)"/>", "eId": "<sch:value-of select="ancestor::tekst:table/@eId"/>", "melding": "De start van de overspanning (@namest) van de cel <sch:value-of select="@namest"/>, in de <sch:value-of select="count(parent::tekst:row/preceding-sibling::tekst:row) + 1"/>e rij, van de <sch:value-of select="local-name(ancestor::tekst:thead | ancestor::tekst:tbody)"/> van tabel <sch:value-of select="ancestor::tekst:table/@eId"/> is niet gelijk aan de @colname van de cel.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern>
      <sch:rule context="tekst:entry[@namest][@nameend]">
         <sch:p>Bij horizontale overspanning MOET de positie van @nameend groter zijn dan de positie
        van @namest</sch:p>
         <sch:let name="start" value="@namest"/>
         <sch:let name="end" value="@nameend"/>
         <sch:let name="colPosities">
            <xsl:for-each select="ancestor::tekst:tgroup/tekst:colspec">
               <xsl:variable name="colnum">
                  <xsl:choose>
                     <xsl:when test="@colnum">
                        <xsl:value-of select="@colnum"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="position()"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <col colnum="{$colnum}" name="{@colname}"/>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="STOP0032"
                     test="xs:integer($colPosities/*[@name = $start]/@colnum) &lt;= xs:integer($colPosities/*[@name = $end]/@colnum)"
                     role="fout">
        {"code": "STOP0032", "naam": "<sch:value-of select="@namest"/>", "nummer": "<sch:value-of select="count(parent::tekst:row/preceding-sibling::tekst:row) + 1"/>", "ouder": "<sch:value-of select="local-name(ancestor::tekst:thead | ancestor::tekst:tbody)"/>", "eId": "<sch:value-of select="ancestor::tekst:table/@eId"/>", "melding": "De entry met @namest \"<sch:value-of select="@namest"/>\", van de <sch:value-of select="count(parent::tekst:row/preceding-sibling::tekst:row) + 1"/>e rij, van de <sch:value-of select="local-name(ancestor::tekst:thead | ancestor::tekst:tbody)"/>, in de tabel met eId: <sch:value-of select="ancestor::tekst:table/@eId"/>, heeft een positie bepaling groter dan de positie van de als @nameend genoemde cel. Corrigeer de gegevens voor de overspanning.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern>
      <sch:rule context="tekst:entry[@colname]">
         <sch:p>De referentie van een cel MOET correct verwijzen naar een kolom</sch:p>
         <sch:let name="id" value="@colname"/>
         <sch:report id="STOP0036"
                     test="not(ancestor::tekst:tgroup/tekst:colspec[@colname = $id])"
                     role="fout"> {"code": "STOP0036", "naam": "colname", "nummer": "<sch:value-of select="count(parent::tekst:row/preceding-sibling::tekst:row) + 1"/>", "ouder": "<sch:value-of select="local-name(ancestor::tekst:thead | ancestor::tekst:tbody)"/>", "eId": "<sch:value-of select="ancestor::tekst:table/@eId"/>", "melding": "De entry met @colname van de <sch:value-of select="count(parent::tekst:row/preceding-sibling::tekst:row) + 1"/>e rij, van <sch:value-of select="local-name(ancestor::tekst:thead | ancestor::tekst:tbody)"/>, van de tabel met id: <sch:value-of select="ancestor::tekst:table/@eId"/> , verwijst niet naar een bestaande kolom. Controleer en corrigeer de identifier voor de kolom (@colname)", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_017">
      <sch:title>Tabel - het aantal cellen is correct</sch:title>
      <sch:rule context="tekst:tgroup/tekst:thead | tekst:tgroup/tekst:tbody">
         <sch:let name="totaalCellen"
                  value="count(tekst:row) * number(parent::tekst:tgroup/@cols)"/>
         <sch:let name="colPosities">
            <xsl:for-each select="parent::tekst:tgroup/tekst:colspec">
               <xsl:variable name="colnum">
                  <xsl:choose>
                     <xsl:when test="@colnum">
                        <xsl:value-of select="@colnum"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="position()"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <col colnum="{$colnum}" name="{@colname}"/>
            </xsl:for-each>
         </sch:let>
         <sch:let name="cellen"
                  value="count(//tekst:entry[not(@wijzigactie = 'verwijder')])"/>
         <sch:let name="spanEinde">
            <xsl:for-each select="self::tekst:tbody//tekst:entry[not(@wijzigactie = 'verwijder')] | self::tekst:thead//tekst:entry[not(@wijzigactie = 'verwijder')]">
               <xsl:variable as="xs:string?" name="namest" select="@namest"/>
               <xsl:variable as="xs:string?" name="nameend" select="@nameend"/>
               <xsl:variable as="xs:integer?"
                             name="numend"
                             select="$colPosities/*[@name = $nameend]/@colnum"/>
               <xsl:variable as="xs:integer?"
                             name="numst"
                             select="$colPosities/*[@name = $namest]/@colnum"/>
               <nr>
                  <xsl:choose>
                     <xsl:when test="$numend and $numst and @morerows">
                        <xsl:value-of select="($numend - $numst + 1) * (@morerows + 1)"/>
                     </xsl:when>
                     <xsl:when test="$numend and $numst">
                        <xsl:value-of select="$numend - $numst + 1"/>
                     </xsl:when>
                     <xsl:when test="@morerows">
                        <xsl:value-of select="1 + @morerows"/>
                     </xsl:when>
                     <xsl:otherwise>1</xsl:otherwise>
                  </xsl:choose>
               </nr>
            </xsl:for-each>
         </sch:let>
         <sch:let name="spannend" value="sum($spanEinde/*)"/>
         <sch:p>Het aantal colspec's MOET gelijk zijn aan het opgegeven aantal kolommen.</sch:p>
         <sch:assert id="STOP0037"
                     test="number(parent::tekst:tgroup/@cols) = count(parent::tekst:tgroup/tekst:colspec)"
                     role="fout"> {"code": "STOP0037", "nummer": "<sch:value-of select="count(parent::tekst:tgroup/tekst:colspec)"/>", "naam": "<sch:name/>", "eId": "<sch:value-of select="ancestor::tekst:table/@eId"/>", "aantal": "<sch:value-of select="parent::tekst:tgroup/@cols"/>", "melding": "Het aantal colspec's (<sch:value-of select="count(parent::tekst:tgroup/tekst:colspec)"/>) voor <sch:name/> in tabel <sch:value-of select="ancestor::tekst:table/@eId"/> komt niet overeen met het aantal kolommen (<sch:value-of select="parent::tekst:tgroup/@cols"/>).", "ernst": "fout"},</sch:assert>
         <sch:p>Het totale aantal cellen MOET overeenkomen met het aantal mogelijke cellen</sch:p>
         <sch:assert id="STOP0038" test="$totaalCellen = $spannend" role="fout"> {"code": "STOP0038", "aantal": "<sch:value-of select="$spannend"/>", "naam": "<sch:name/>", "eId": "<sch:value-of select="ancestor::tekst:table/@eId"/>", "nummer": "<sch:value-of select="$totaalCellen"/>", "melding": "Het aantal cellen in <sch:name/> van tabel \"<sch:value-of select="ancestor::tekst:table/@eId"/>\" komt niet overeen met de verwachting (resultaat: <sch:value-of select="$spannend"/> van verwachting <sch:value-of select="$totaalCellen"/>).", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_033">
      <sch:title>Externe referentie, notatie</sch:title>
      <sch:rule context="tekst:ExtRef">
         <sch:let name="notatie">
            <xsl:choose>
               <xsl:when test="@soort = 'AKN'">/akn/</xsl:when>
               <xsl:when test="@soort = 'JCI'">jci1</xsl:when>
               <xsl:when test="@soort = 'URL'">http</xsl:when>
               <xsl:when test="@soort = 'JOIN'">/join/</xsl:when>
               <xsl:when test="@soort = 'document'"/>
            </xsl:choose>
         </sch:let>
         <sch:p>Een externe referentie MOET de juiste notatie gebruiken</sch:p>
         <sch:assert id="STOP0050" test="starts-with(@ref, $notatie)" role="fout">{"code": "STOP0050", "type": "<sch:value-of select="@soort"/>", "ref": "<sch:value-of select="@ref"/>", "melding": "De ExtRef van het type <sch:value-of select="@soort"/> met referentie <sch:value-of select="@ref"/> heeft niet de juiste notatie.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_037">
      <sch:title>Gereserveerd zonder opvolgende elementen</sch:title>
      <sch:rule context="tekst:Gereserveerd[not(ancestor::tekst:Vervang)][not(ancestor::tekst:Artikel)]">
         <sch:p>Het element Gereserveerd MAG GEEN opvolgende elementen op hetzelfde niveau
        hebben</sch:p>
         <sch:assert id="STOP0055" test="not(following-sibling::tekst:*)" role="fout"> {"code": "STOP0055", "naam": "<sch:value-of select="local-name(following-sibling::tekst:*[1])"/>", "element": "<sch:value-of select="local-name(parent::tekst:*)"/>", "eId": "<sch:value-of select="parent::tekst:*/@eId"/>", "melding": "Het element <sch:value-of select="local-name(following-sibling::tekst:*[1])"/> binnen <sch:value-of select="local-name(parent::tekst:*)"/> met eId: \"<sch:value-of select="parent::tekst:*/@eId"/>\" is niet toegestaan na een element Gereserveerd. Verwijder het element Gereserveerd of verplaats dit element naar een eigen structuur of tekst.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_070">
      <sch:title>Vervallen zonder opvolgende elementen</sch:title>
      <sch:rule context="tekst:Artikel[not(ancestor::tekst:Vervang)]">
         <sch:p>Het element Artikel met Inhoud MAG GEEN andere elementen met op hetzelfde niveau
        hebben</sch:p>
         <sch:report id="STOP0070"
                     test="(child::tekst:Lid and (child::tekst:Inhoud or child::tekst:Vervallen or child::tekst:Gereserveerd)) or (child::tekst:Inhoud and (child::tekst:Vervallen or child::tekst:Gereserveerd))"
                     role="fout"> {"code": "STOP0070", "naam": "<sch:value-of select="local-name()"/>", "eId": "<sch:value-of select="@eId"/>", "melding": "Het <sch:value-of select="local-name()"/> met eId '<sch:value-of select="@eId"/>' heeft een combinatie van elementen dat niet is toegestaan. Corrigeer het artikel door de combinatie van elementen te verwijderen.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_039">
      <sch:title>Structuur compleet</sch:title>
      <sch:rule context="tekst:Afdeling | tekst:Bijlage | tekst:Boek | tekst:Deel | tekst:Divisie | tekst:Hoofdstuk | tekst:Paragraaf | tekst:Subparagraaf | tekst:Subsubparagraaf | tekst:Titel[not(parent::tekst:Figuur)]">
         <sch:p>Een structuur-element MOET altijd ten minste een element na de Kop bevatten</sch:p>
         <sch:assert id="STOP0058"
                     test="child::tekst:*[not(self::tekst:Kop)]"
                     role="fout"> {"code": "STOP0058", "naam": "<sch:name/>", "eId": "<sch:value-of select="@eId"/>", "melding": "Het element <sch:name/> met eId: \"<sch:value-of select="@eId"/> is niet compleet, een kind-element anders dan een Kop is verplicht. Completeer of verwijder dit structuur-element.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_041">
      <sch:title>Divisietekst compleet</sch:title>
      <sch:rule context="tekst:Divisietekst">
         <sch:p>Een Divisietekst MOET altijd een element anders dan een Kop bevatten</sch:p>
         <sch:assert id="STOP0060"
                     test="child::tekst:*[not(self::tekst:Kop)]"
                     role="fout"> {"code": "STOP0060", "naam": "<sch:name/>", "eId": "<sch:value-of select="@eId"/>", "melding": "Het element <sch:name/> met eId: \"<sch:value-of select="@eId"/> is niet compleet, een kind-element anders dan een Kop is verplicht. Completeer of verwijder dit element.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_043">
      <sch:title>Kennisgeving zonder divisie</sch:title>
      <sch:rule context="tekst:Divisie[ancestor::tekst:Kennisgeving]">
         <sch:report id="STOP0061" test="." role="fout">{"code": "STOP0061", "eId": "<sch:value-of select="@eId"/>", "melding": "De kennisgeving bevat een Divisie met eId <sch:value-of select="@eId"/>. Dit is niet toegestaan. Gebruik alleen Divisietekst.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_044">
      <sch:title>Vervallen structuur</sch:title>
      <sch:rule context="tekst:Vervallen[not(ancestor::tekst:Vervang)][not(parent::tekst:Artikel)][not(parent::tekst:Divisietekst)]">
         <sch:p>Indien een structuur-element vervallen is dan moeten ook alle onderliggende delen
        (structuur en tekst) vervallen zijn</sch:p>
         <sch:report id="STOP0062"
                     test="following-sibling::tekst:*[not(child::tekst:Vervallen)]"
                     role="fout">{"code": "STOP0062", "naam": "<sch:value-of select="local-name(parent::tekst:*)"/>", "eId": "<sch:value-of select="parent::tekst:*/@eId"/>", "element": "<sch:value-of select="local-name(following-sibling::tekst:*[not(child::tekst:Vervallen)][1])"/>", "id": "<sch:value-of select="following-sibling::tekst:*[not(child::tekst:Vervallen)][1]/@eId"/>", "melding": "Het element <sch:value-of select="local-name(parent::tekst:*)"/> met eId: \"<sch:value-of select="parent::tekst:*/@eId"/>\" is vervallen, maar heeft minstens nog een niet vervallen element\". Controleer vanaf element <sch:value-of select="local-name(following-sibling::tekst:*[not(child::tekst:Vervallen)][1])"/> met eId \"<sch:value-of select="following-sibling::tekst:*[not(child::tekst:Vervallen)][1]/@eId"/> of alle onderliggende elementen als vervallen zijn aangemerkt.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_045">
      <sch:rule context="tekst:Contact">
         <sch:let name="pattern">
            <xsl:choose>
               <xsl:when test="@soort = 'e-mail'">[^@]+@[^\.]+\..+</xsl:when>
               <xsl:otherwise>[onbekend-soort-adres]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="adres" value="@adres/./string()"/>
         <sch:p>Als het element tekst:Contact een attribuut @adres heeft, moet de inhoud van het
        attribuut een adres zijn dat is geformatteerd volgens de specificaties van de waarde van
        attribuut @soort.</sch:p>
         <sch:assert id="STOP0064" test="matches($adres, $pattern)" role="fout">
        {"code": "STOP0064", "adres": "<sch:value-of select="./string()"/>", "eId": "<sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/>", "melding": "Het e-mailadres <sch:value-of select="./string()"/> zoals genoemd in het element Contact met eId <sch:value-of select="ancestor::tekst:*[@eId][1]/@eId"/> moet een correct geformatteerd e-mailadres zijn. Corrigeer het e-mailadres.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_046">
      <sch:rule context="tekst:Motivering[@schemaversie]">
         <sch:report id="STOP0075"
                     test="ancestor::tekst:BesluitCompact|ancestor::tekst:BesluitKlassiek"
                     role="fout">
        {"code": "STOP0075", "schemaversie": "<sch:value-of select="@schemaversie"/>", "melding": "Het attribuut schemaversie (met waarde <sch:value-of select="@schemaversie"/>) bij tekst:Motivering mag niet gebruikt worden binnen tekst:BesluitCompact of tekst:BesluitKlassiek. Verwijder het attribuut schemaversie bij tekst:Motivering", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_081">
      <sch:title>Toelichting specifiek</sch:title>
      <sch:rule context="tekst:Toelichting">
         <sch:let name="aantalKinderen"
                  value="count(tekst:ArtikelgewijzeToelichting | tekst:AlgemeneToelichting)"/>
         <sch:p>ontraden: De Toelichting heeft een structuur met Divisie of Divisietekst</sch:p>
         <sch:report id="STOP0081"
                     test="child::tekst:Divisie | child::tekst:Divisietekst"
                     role="ontraden">
      {"code": "STOP0081", "eId": "<sch:value-of select="@eId"/>", "melding": "De Toelichting met eId <sch:value-of select="@eId"/> heeft een structuur met Divisie of Divisietekst dat zal in de toekomst niet meer toegestaan zijn. Advies is om deze Divisie / Divisietekst elementen in een element AlgemeneToelichting of ArtikelgewijzeToelichting te plaatsen, indien mogelijk.", "ernst": "ontraden"},</sch:report>
         <!--  -->
         <sch:p>Toelichting moet een Kop hebben indien meer dan 1 Toelichting onderdelen</sch:p>
         <sch:report id="STOP0084"
                     test="xs:int($aantalKinderen) &gt;1 and not(child::tekst:Kop)"
                     role="fout">
      {"code": "STOP0084", "eId": "<sch:value-of select="@eId"/>", "melding": "Het element Toelichting met eId <sch:value-of select="@eId"/> moet een Kop hebben omdat zowel een ArtikelgewijzeToelichting en een AlgemeneToelichting in de Toelichting zijn opgenomen. Geef de Toelichting een Kop met duidelijke tekstuele omschrijving.", "ernst": "fout"},</sch:report>
         <!--  -->
         <sch:p>Toelichting mag geen Kop hebben indien slechts 1 Toelichting onderdeel</sch:p>
         <sch:report id="STOP0085"
                     test="xs:int($aantalKinderen) =1 and child::tekst:Kop"
                     role="fout">
      {"code": "STOP0085", "eId": "<sch:value-of select="@eId"/>", "localName": "<sch:value-of select="local-name(child::tekst:*[2])"/>", "melding": "Het element Toelichting met eId <sch:value-of select="@eId"/> heeft een Kop; deze is niet toegestaan omdat het enige onderliggende element <sch:value-of select="local-name(child::tekst:*[2])"/> al een Kop heeft. Verwijder de Kop voor het element Toelichting.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_082">
      <sch:title>ArtikelgewijzeToelichting buiten Toelichting</sch:title>
      <sch:rule context="tekst:ArtikelgewijzeToelichting">
         <sch:p>Een ArtikelgewijzeToelichting geplaatst buiten een element Toelichting</sch:p>
         <sch:assert id="STOP0082" test="parent::tekst:Toelichting" role="ontraden">
      {"code": "STOP0082", "eId": "<sch:value-of select="@eId"/>", "melding": "De Toelichting met eId <sch:value-of select="@eId"/> heeft een structuur met Divisie of Divisietekst dat zal in de toekomst niet meer toegestaan zijn. Advies is om deze Divisie / Divisietekst elementen in een element AlgemeneToelichting of ArtikelgewijzeToelichting te plaatsen indien mogelijk.", "ernst": "ontraden"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_tekst_083">
      <sch:title>Inleidende tekst in Toelichtingen</sch:title>
      <sch:rule context="tekst:AlgemeneToelichting | tekst:ArtikelgewijzeToelichting | tekst:Toelichting">
         <sch:p>Gebruik van een Inleidendetekst in een Toelichting, AlgemeneToelichting of ArtikelgewijzeToelichting</sch:p>
         <sch:report id="STOP0083" test="child::tekst:InleidendeTekst" role="ontraden">
      {"code": "STOP0083", "eId": "<sch:value-of select="@eId"/>", "localName": "<sch:value-of select="local-name()"/>", "melding": "De <sch:value-of select="local-name()"/> met eId <sch:value-of select="@eId"/> heeft een element InleidendeTekst dat zal in de toekomst niet meer toegestaan zijn. Advies is om deze InleidendeTekst te verwijderen of als Divisietekst op te nemen.", "ernst": "ontraden"},</sch:report>
      </sch:rule>
   </sch:pattern>
</sch:schema>
