<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:data="https://standaarden.overheid.nl/stop/imop/data/"
            xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:ns prefix="data" uri="https://standaarden.overheid.nl/stop/imop/data/"/>
   <sch:ns prefix="tekst" uri="https://standaarden.overheid.nl/stop/imop/tekst/"/>
   <sch:ns prefix="lvbba"
           uri="https://standaarden.overheid.nl/lvbb/stop/aanlevering/"/>
   <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
   <sch:p>Versie 1.2.0</sch:p>
   <sch:p>Schematron voor aanvullende validaties voor lvbba</sch:p>
   <sch:pattern id="sch_lvbba_003">
      <sch:title>BeoogdInformatieobject in overeenstemming met ExtIoRef/@eId</sch:title>
      <sch:let name="verzamelXioRefs">
         <xsl:for-each select="/lvbba:AanleveringBesluit/lvbba:BesluitVersie[//data:BeoogdInformatieobject]//tekst:ExtIoRef[not(ancestor-or-self::tekst:*[@wijzigactie = 'verwijder'])][not(ancestor::tekst:Verwijder)]">
            <set>
               <id>
                  <xsl:if test="ancestor::tekst:*[@componentnaam][1]">
                     <xsl:value-of select="concat('!', ancestor::tekst:*[@componentnaam][1]/@componentnaam, '#')"/>
                  </xsl:if>
                  <xsl:value-of select="@eId"/>
               </id>
               <join>
                  <xsl:value-of select="@ref"/>
               </join>
            </set>
         </xsl:for-each>
      </sch:let>
      <sch:rule context="lvbba:AanleveringBesluit//data:BeoogdInformatieobject">
         <sch:let name="joinID" value="normalize-space(data:instrumentVersie/./string())"/>
         <sch:let name="data-eId" value="normalize-space(data:eId/./string())"/>
         <sch:p>De eId en Instrumentversie van elk BeoogdInformatieobject bij een besluit MOET
        d.m.v. een corresponderende ExtIORef (attributen eId en ref komen overeen) 
        genoemd worden in de regeling(mutatie).</sch:p>
         <sch:assert id="BHKV1036"
                     test="$verzamelXioRefs/set/id[. = $data-eId] and $verzamelXioRefs/set[id[. = $data-eId]]/join = $joinID"
                     role="fout"> {"code": "BHKV1036", "eId": "<sch:value-of select="$data-eId"/>", "instrument": "<sch:value-of select="$joinID"/>", "melding": "De identifier van instrumentVersie \"<sch:value-of select="$joinID"/>\" komt niet overeen met de ExtIoRef met eId \"<sch:value-of select="$data-eId"/>\". Corrigeer de identifier of de eId zodat deze gelijk zijn.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_004">
      <sch:title>Tijdstempels in ontwerpbesluit</sch:title>
      <sch:rule context="data:BesluitMetadata/data:soortProcedure[normalize-space(./string()) = '/join/id/stop/proceduretype_ontwerp']">
         <sch:p>Voor een ontwerpbesluit MAG GEEN tijdstempel worden meegeleverd</sch:p>
         <sch:report id="BHKV1004"
                     test="ancestor::lvbba:AanleveringBesluit//data:ConsolidatieInformatie/data:Tijdstempels"
                     role="fout"> {"code": "BHKV1004", "melding": "Het ontwerpbesluit heeft tijdstempels, dit is niet toegestaan. Verwijder de tijdstempels.", "ernst": "fout"},</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_005">
      <sch:title>Besluit met soort werk '/join/id/stop/work_003'</sch:title>
      <sch:rule context="lvbba:AanleveringBesluit/lvbba:BesluitVersie">
         <sch:let name="soortWork"
                  value="normalize-space(data:ExpressionIdentificatie/data:soortWork/./string())"/>
         <sch:p>De identificatie van het besluit moet als soort werk '/join/id/stop/work_003'
        hebben</sch:p>
         <sch:assert id="BHKV1005"
                     test="$soortWork = '/join/id/stop/work_003'"
                     role="fout">{"code": "BHKV1005", "id": "<sch:value-of select="$soortWork"/>", "melding": "Het geleverde besluit heeft als soortWork '<sch:value-of select="$soortWork"/>' , Dit moet zijn: '/join/id/stop/work_003'.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_006">
      <sch:title>Regeling met soort werk '/join/id/stop/work_019</sch:title>
      <sch:rule context="tekst:RegelingCompact | tekst:RegelingKlassiek | tekst:RegelingVrijetekst">
         <sch:let name="soortWork" value="'/join/id/stop/work_019'"/>
         <sch:let name="wordt" value="normalize-space(xs:string(@wordt))"/>
         <sch:let name="controle">
            <xsl:for-each select="ancestor::lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie">
               <xsl:choose>
                  <xsl:when test="normalize-space(data:ExpressionIdentificatie/data:soortWork/xs:string(.)) = $soortWork and               normalize-space(data:ExpressionIdentificatie/data:FRBRExpression/xs:string(.)) = $wordt">|GOED|</xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="concat(normalize-space(data:ExpressionIdentificatie/data:soortWork/./string()), ' ')"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </sch:let>
         <sch:p>De identificatie van een RegelingCompact, RegelingKlassiek of RegelingVrijetekst moet
        als soortWork '/join/id/stop/work_019' hebben</sch:p>
         <sch:assert id="BHKV1006" test="contains($controle, '|GOED|')" role="fout">{"code": "BHKV1006", "id": "<sch:value-of select="normalize-space(replace($controle, ' /', ', /'))"/>", "melding": "Het geleverde regelingversie heeft als soortWork '<sch:value-of select="normalize-space(replace($controle, ' /', ', /'))"/>'. Dit moet voor een RegelingCompact, RegelingKlassiek of RegelingVrijetekst zijn '/join/id/stop/work_019'", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_009">
      <sch:title>eId van BeoogdeRegeling in Besluit</sch:title>
      <sch:rule context="data:BeoogdeRegeling">
         <sch:let name="eId" value="normalize-space(data:eId/./string())"/>
         <sch:let name="matchId">
            <xsl:choose>
               <xsl:when test="starts-with($eId, '!')">
                  <xsl:value-of select="substring-after(replace($eId, '!', ''), '#')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$eId"/>
               </xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="component">
            <xsl:choose>
               <xsl:when test="starts-with($eId, '!')">
                  <xsl:value-of select="substring-before(replace($eId, '!', ''), '#')"/>
               </xsl:when>
               <xsl:otherwise>[geen_component]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:p>In BeoogdeRegeling moet de daarin genoemde eId voorkomen voorkomen in het Besluit
        (bij BesluitCompact in het besluit-deel, dus NIET in de <codeph>WijzigBijlage</codeph>,
        bij BesluitKlassiek in <codeph>RegelingKlassiek</codeph>)
        danwel in de Rectificatie(in <codeph>BesluitMutatie</codeph>)</sch:p>
         <sch:assert id="BHKV1009"
                     test="           ancestor::lvbba:BesluitVersie/tekst:BesluitCompact//tekst:Artikel[@eId = $matchId][not(ancestor::tekst:WijzigBijlage)] |           ancestor::lvbba:BesluitVersie/tekst:BesluitCompact//tekst:WijzigArtikel[@eId = $matchId][not(ancestor::tekst:WijzigBijlage)] |           ancestor::lvbba:BesluitVersie//tekst:RegelingKlassiek/tekst:Lichaam//tekst:Artikel[@eId = $matchId][ancestor::tekst:RegelingKlassiek[@componentnaam = $component]] |           ancestor::lvbba:BesluitVersie//tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel[@eId = $matchId][ancestor::tekst:RegelingKlassiek[@componentnaam = $component]] |           ancestor::lvbba:AanleverenRectificatie//tekst:BesluitMutatie[@componentnaam = $component]//tekst:*[@eId = $matchId]"
                     role="fout">
        {"code": "BHKV1009", "eId": "<sch:value-of select="$eId"/>", "regeling": "<sch:value-of select="data:instrumentVersie"/>", "melding": "In het besluit of rectificatie is de eId <sch:value-of select="$eId"/> voor de BeoogdeRegeling <sch:value-of select="data:instrumentVersie"/> niet te vinden. Controleer de referentie naar het besluit.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_010">
      <sch:title>eId van Tijdstempel in Besluit</sch:title>
      <sch:rule context="data:ConsolidatieInformatie/data:Tijdstempels/data:Tijdstempel[data:eId]">
         <sch:let name="refID" value="normalize-space(data:eId/./string())"/>
         <sch:let name="matchID">
            <xsl:choose>
               <xsl:when test="starts-with($refID, '!')">
                  <xsl:value-of select="substring-after($refID, '#')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$refID"/>
               </xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="component">
            <xsl:choose>
               <xsl:when test="starts-with($refID, '!')">
                  <xsl:value-of select="substring-before(translate($refID, '!', ''), '#')"/>
               </xsl:when>
               <xsl:when test="ancestor::tekst:*[@componentnaam][1]">
                  <xsl:value-of select="ancestor::tekst:*[@componentnaam][1]/@componentnaam"/>
               </xsl:when>
               <xsl:otherwise>[is_geen_component]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:p>In een Tijdstempel moet de daarin genoemde eId voorkomen in het Besluit (maar NIET in het regelingdeel van het besluit)</sch:p>
         <sch:assert id="BHKV1010"
                     test="           ancestor::lvbba:BesluitVersie/tekst:BesluitCompact//tekst:Artikel[@eId = $matchID][not(ancestor::tekst:WijzigBijlage)] |           ancestor::lvbba:BesluitVersie//tekst:RegelingKlassiek/tekst:Lichaam//tekst:Artikel[@eId = $matchID][ancestor::tekst:RegelingKlassiek[@componentnaam = $component]] |           ancestor::lvbba:AanleverenRectificatie//tekst:BesluitMutatie[@componentnaam = $component]//tekst:*[@eId = $matchID]"
                     role="fout">
        {"code": "BHKV1010", "eId": "<sch:value-of select="$refID"/>", "melding": "In het besluit of rectificatie is de eId <sch:value-of select="$refID"/> voor de tijdstempel niet te vinden. Controleer de referentie naar het besluit.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_011">
      <sch:title>eId van data:Intrekking in Besluit</sch:title>
      <sch:rule context="data:ConsolidatieInformatie/data:Intrekkingen/data:Intrekking[starts-with(xs:string(data:instrument), '/akn/')]">
         <sch:let name="refID" value="normalize-space(data:eId/./string())"/>
         <sch:let name="matchID">
            <xsl:choose>
               <xsl:when test="starts-with($refID, '!')">
                  <xsl:value-of select="substring-after($refID, '#')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$refID"/>
               </xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="component">
            <xsl:choose>
               <xsl:when test="starts-with($refID, '!')">
                  <xsl:value-of select="substring-before(translate($refID, '!', ''), '#')"/>
               </xsl:when>
               <xsl:when test="ancestor::tekst:*[@componentnaam][1]">
                  <xsl:value-of select="ancestor::tekst:*[@componentnaam][1]/@componentnaam"/>
               </xsl:when>
               <xsl:otherwise>[is_geen_component]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:p>In een Intrekking moet de daarin genoemde eId voorkomen in het Besluit(maar NIET in het regelingdeel van het besluit)</sch:p>
         <sch:assert id="BHKV1011"
                     test="           ancestor::lvbba:BesluitVersie/tekst:BesluitCompact//tekst:Artikel[@eId = $matchID][not(ancestor::tekst:WijzigBijlage)] |           ancestor::lvbba:BesluitVersie/tekst:BesluitCompact//tekst:WijzigArtikel[@eId = $matchID][not(ancestor::tekst:WijzigBijlage)] |                  ancestor::lvbba:BesluitVersie//tekst:RegelingKlassiek/tekst:Lichaam//tekst:Artikel[@eId = $matchID][ancestor::tekst:RegelingKlassiek[@componentnaam = $component]] |           ancestor::lvbba:BesluitVersie//tekst:RegelingKlassiek/tekst:Lichaam//tekst:WijzigArtikel[@eId = $matchID][ancestor::tekst:RegelingKlassiek[@componentnaam = $component]] |           ancestor::lvbba:AanleverenRectificatie//tekst:BesluitMutatie[@componentnaam = $component]//tekst:*[@eId = $matchID]"
                     role="fout">
        {"code": "BHKV1011", "eId": "<sch:value-of select="$refID"/>", "instrumentversieRegeling": "<sch:value-of select="data:instrument"/>", "melding": "In het besluit of rectificatie is de eId <sch:value-of select="$refID"/> voor de data:Intrekking van de regeling <sch:value-of select="data:instrument"/> niet te vinden. Controleer de referentie naar het besluit/rectificatie.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_021">
      <sch:title>Regeling met soort werk '/join/id/stop/work_021</sch:title>
      <sch:rule context="tekst:RegelingTijdelijkdeel">
         <sch:let name="soortWork" value="'/join/id/stop/work_021'"/>
         <sch:let name="wordt" value="xs:string(@wordt)"/>
         <sch:p>De identificatie van een RegelingTijdelijkdeel moet als soortWork
        '/join/id/stop/work_021' hebben</sch:p>
         <sch:assert id="BHKV1028"
                     test="ancestor::lvbba:AanleveringBesluit//data:ExpressionIdentificatie[normalize-space(xs:string(data:soortWork)) = $soortWork][normalize-space(xs:string(data:FRBRExpression)) = $wordt]"
                     role="fout">
        {"code": "BHKV1028", "id": "<sch:value-of select="$wordt"/>", "melding": "Het besluit heeft tekst:RegelingTijdelijkdeel met attribuut wordt=\"<sch:value-of select="$wordt"/>\", maar data:ExpressionIdentificatie met <sch:value-of select="$wordt"/> ontbreekt, of heeft als data:soortWork geen '/join/id/stop/work_021'. Corrigeer de data:ExpressionIdentificatie of tekst:RegelingTijdelijkdeel.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_044">
      <sch:title>Een @wordt-versie in een besluit komt overeen met de FRBRExpression
      identificatie</sch:title>
      <sch:rule context="lvbba:AanleveringBesluit//tekst:*[@componentnaam]">
         <sch:let name="wordt" value="normalize-space(xs:string(@wordt))"/>
         <sch:let name="worden"
                  value="count(ancestor::lvbba:AanleveringBesluit//lvbba:RegelingVersieInformatie[data:ExpressionIdentificatie/data:FRBRExpression=$wordt])"/>
         <sch:let name="FRBRexpression">
            <xsl:for-each select="ancestor::lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie">
               <xsl:choose>
                  <xsl:when test="$wordt = normalize-space(data:ExpressionIdentificatie/xs:string(data:FRBRExpression))"/>
                  <xsl:otherwise>
                     <xsl:value-of select="concat(normalize-space(data:ExpressionIdentificatie/xs:string(data:FRBRExpression)), ' ')"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </sch:let>
         <sch:let name="melding">
            <xsl:choose>
               <xsl:when test="$worden &gt; 1">, of de data:FRBRExpression komt vaker dan 1x voor.</xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </sch:let>
         <sch:p>Een @wordt-versie in een besluit is gelijk aan de meegeleverde FRBRExpression
        identificatie van regelingversieinformatie</sch:p>
         <sch:assert id="BHKV1044" test="$worden = 1" role="fout">
        {"code": "BHKV1044", "wordt": "<sch:value-of select="normalize-space($wordt)"/>", "component": "<sch:value-of select="@componentnaam"/>", "melding": "Er moet versieinformatie meegeleverd worden voor \"<sch:value-of select="normalize-space($wordt)"/>\" van component \"<sch:value-of select="@componentnaam"/>\", deze ontbreekt <sch:value-of select="$melding"/>. Voeg versieinformatie toe of verwijder de dubbele.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_046">
      <sch:title>Procedurestap Publicatie</sch:title>
      <sch:rule context="lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:Procedureverloop/data:procedurestappen">
         <sch:assert id="BHKV1046"
                     test="not(data:Procedurestap[data:soortStap[. = '/join/id/stop/procedure/stap_004']])"
                     role="fout">
        {"code": "BHKV1046", "melding": "Het aangeleverde Procedureverloop bevat een stap Publicatie. Dit is niet toegestaan. Verwijder de stap Publicatie.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_047">
      <sch:title>definitief besluit ALLEEN de procedurestappen</sch:title>
      <sch:rule context="lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:Procedureverloop/data:procedurestappen[normalize-space(ancestor::lvbba:BesluitVersie/data:BesluitMetadata/data:soortProcedure/./string()) = '/join/id/stop/proceduretype_definitief']">
         <sch:let name="stappen">
            <xsl:for-each select="data:Procedurestap/data:soortStap">
               <xsl:choose>
                  <xsl:when test="normalize-space(./string()) = '/join/id/stop/procedure/stap_002'"/>
                  <xsl:when test="normalize-space(./string()) = '/join/id/stop/procedure/stap_003'"/>
                  <xsl:otherwise>
                     <xsl:value-of select="normalize-space(.)"/>
                     <xsl:text>, </xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="BHKV1047" test="$stappen = ''" role="fout">
        {"code": "BHKV1047", "soortStap": "<sch:value-of select="normalize-space($stappen)"/>", "melding": "Procedurestap(pen) \"<sch:value-of select="normalize-space($stappen)"/>\" is/zijn niet toegestaan bij een Aanlevering definitief besluit. Verwijder deze stap(pen).", "ernst": "fout"},</sch:assert>
         <sch:p>definitief besluit met procedurestap Ondertekening</sch:p>
         <sch:assert id="BHKV1048"
                     test="data:Procedurestap[normalize-space(data:soortStap/./string()) = '/join/id/stop/procedure/stap_003']"
                     role="fout">
        {"code": "BHKV1048", "melding": "Procedurestap Ondertekening ontbreekt bij een Aanlevering definitief besluit, deze is verplicht. Voeg deze stap toe.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_049">
      <sch:title>ontwerp besluit ALLEEN de procedurestappen</sch:title>
      <sch:rule context="lvbba:AanleveringBesluit/lvbba:BesluitVersie/data:Procedureverloop/data:procedurestappen[normalize-space(ancestor::lvbba:BesluitVersie/data:BesluitMetadata/data:soortProcedure/./string()) = '/join/id/stop/proceduretype_ontwerp']">
         <sch:let name="stappen">
            <xsl:for-each select="data:Procedurestap/data:soortStap">
               <xsl:choose>
                  <xsl:when test="normalize-space(./string()) = '/join/id/stop/procedure/stap_002'"/>
                  <xsl:when test="normalize-space(./string()) = '/join/id/stop/procedure/stap_003'"/>
                  <xsl:otherwise>
                     <xsl:value-of select="normalize-space(.)"/>
                     <xsl:text>, </xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </sch:let>
         <sch:assert id="BHKV1049" test="$stappen = ''" role="fout">
        {"code": "BHKV1049", "soortStap": "<sch:value-of select="normalize-space($stappen)"/>", "melding": "Procedurestap \"<sch:value-of select="normalize-space($stappen)"/>\" is niet toegestaan bij een Aanlevering ontwerp besluit. Verwijder deze stap.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_057">
      <sch:title>kennisgeving procedurestappen</sch:title>
      <sch:rule context="lvbba:AanleveringKennisgeving//data:Procedureverloop/data:procedurestappen/data:Procedurestap/data:soortStap">
         <sch:let name="stappen"
                  value="'/join/id/stop/procedure/stap_005|/join/id/stop/procedure/stap_014|/join/id/stop/procedure/stap_016|/join/id/stop/procedure/stap_015'"/>
         <sch:p>Bij een kennisgeving alleen de volgende procedurestappen</sch:p>
         <sch:assert id="BHKV1057"
                     test="matches(normalize-space(./text()), $stappen)"
                     role="fout">
        {"code": "BHKV1057", "soortStap": "<sch:value-of select="normalize-space(./text())"/>", "melding": "Procedurestap \"<sch:value-of select="normalize-space(./text())"/>\" is niet toegestaan bij een Aanlevering kennisgeving. Verwijder deze stap.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_058">
      <sch:title>FRBRExpression-identificatie RegelingVersieInformatie bij regelingmutatie</sch:title>
      <sch:rule context="lvbba:AanleveringBesluit/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie |       lvbba:AanleveringRectificatie/lvbba:RegelingVersieInformatie/data:ExpressionIdentificatie">
         <sch:let name="FRBRexpression"
                  value="normalize-space(xs:string(data:FRBRExpression))"/>
         <sch:let name="testWordtID">
            <xsl:choose>
               <xsl:when test="ancestor::lvbba:AanleveringBesluit//tekst:RegelingMutatie[xs:string(@wordt) = $FRBRexpression] |             ancestor::lvbba:AanleveringRectificatie//tekst:RegelingMutatie[xs:string(@wordt) = $FRBRexpression]">
                  <xsl:text>[goed]</xsl:text>
               </xsl:when>
               <xsl:when test="ancestor::lvbba:AanleveringBesluit//tekst:RegelingKlassiek[xs:string(@wordt) = $FRBRexpression]">
                  <xsl:text>[goed]</xsl:text>
               </xsl:when>
               <xsl:when test="ancestor::lvbba:AanleveringBesluit//tekst:RegelingCompact[xs:string(@wordt) = $FRBRexpression]">
                  <xsl:text>[goed]</xsl:text>
               </xsl:when>
               <xsl:when test="ancestor::lvbba:AanleveringBesluit//tekst:RegelingVrijetekst[xs:string(@wordt) = $FRBRexpression]">
                  <xsl:text>[goed]</xsl:text>
               </xsl:when>
               <xsl:when test="ancestor::lvbba:AanleveringBesluit//tekst:RegelingTijdelijkdeel[xs:string(@wordt) = $FRBRexpression]">
                  <xsl:text>[goed]</xsl:text>
               </xsl:when>
               <xsl:otherwise>[FRBRexpression-niet gevonden]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:p>FRBRExpression-identificatie van lvbba:RegelingVersieInformatie MOET bij een 
        regelingmutatie voorkomen als @wordt RegelingMutatie of als @wordt bij een initiele regeling</sch:p>
         <sch:assert id="BHKV1058" test="$testWordtID = '[goed]'" role="fout">
        {"code": "BHKV1058", "FRBRExpression": "<sch:value-of select="$FRBRexpression"/>", "melding": "Voor de FRBRExpression (<sch:value-of select="$FRBRexpression"/>) is RegelingVersieInformatie aangeleverd, maar deze regelingversie komt niet voor in het Besluit als initiele regeling of als regelingmutatie. Verwijder de RegelingVersieInformatie, of voeg de FRBRExpression toe in een wordt attribuut.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_063">
      <sch:title>Intrekking van een informatieobject</sch:title>
      <sch:rule context="data:ConsolidatieInformatie/data:Intrekkingen/data:Intrekking[starts-with(xs:string(data:instrument), '/join/id/')]">
         <sch:let name="refID" value="normalize-space(xs:string(data:eId))"/>
         <sch:let name="matchID">
            <xsl:choose>
               <xsl:when test="starts-with($refID, '!') and contains($refID, '#')">
                  <xsl:value-of select="substring-after($refID, '#')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$refID"/>
               </xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:let name="component">
            <xsl:choose>
               <xsl:when test="starts-with($refID, '!') and contains($refID, '#')">
                  <xsl:value-of select="substring-before(translate($refID, '!', ''), '#')"/>
               </xsl:when>
               <xsl:when test="ancestor::tekst:*[@componentnaam][1]">
                  <xsl:value-of select="ancestor::tekst:*[@componentnaam][1]/@componentnaam"/>
               </xsl:when>
               <xsl:otherwise>[is_geen_component]</xsl:otherwise>
            </xsl:choose>
         </sch:let>
         <sch:p>Een Intrekking van een informatieobject
        MOET genoemd worden in tekst:ExtIORef in een RegelingMutatie, met een 
        wijzig- of verwijder-actie</sch:p>
         <sch:assert id="bhkv1063"
                     test="         ancestor::lvbba:BesluitVersie/tekst:BesluitCompact/tekst:WijzigBijlage//tekst:RegelingMutatie[@componentnaam = $component]//tekst:ExtIoRef[@eId = $matchID][ancestor::tekst:Verwijder or ancestor::tekst:*/@wijzigactie='verwijder' or ancestor::tekst:VerwijderdeTekst] |         ancestor::lvbba:BesluitVersie//tekst:RegelingKlassiek/tekst:Lichaam//tekst:RegelingMutatie[@componentnaam = $component]//tekst:ExtIoRef[@eId = $matchID][ancestor::tekst:Verwijder or ancestor::tekst:*/@wijzigactie='verwijder' or ancestor::tekst:VerwijderdeTekst]"
                     role="fout">
        {"code": "BHKV1063", "eId": "<sch:value-of select="$refID"/>", "instrumentIO": "<sch:value-of select="data:instrument"/>", "melding": "De eId(<sch:value-of select="$refID"/>) van de data:Intrekking van <sch:value-of select="data:instrument"/> is niet van een ExtIoRef binnen een wijzig- of verwijder- actie, tekst:verwijder of een tekst:verwijderdeTekst. Pas de eId aan, of plaats de ExtIoRef binnen een element met een wijzig- of verwijder- actie, tekst:verwijder of tekst:verwijderdeTekst.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_066">
      <sch:title>Procedureverloop verplicht bij definitief besluit</sch:title>
      <sch:rule context="data:BesluitMetadata[data:soortProcedure='/join/id/stop/proceduretype_definitief']">
         <sch:assert id="BHKV1066"
                     test="ancestor::lvbba:BesluitVersie/data:Procedureverloop"
                     role="fout">
        {"code": "BHKV1066", "expressie-id": "<sch:value-of select="ancestor::lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRExpression"/>", "melding": "Het aangeleverde besluit(<sch:value-of select="ancestor::lvbba:BesluitVersie/data:ExpressionIdentificatie/data:FRBRExpression"/>) heeft als data:soortProcedure '/join/id/stop/proceduretype_definitief', maar heeft geen data:Procedureverloop module. Dit is niet toegestaan. Voeg module data:Procedureverloop toe, of wijzig data:soortProcedure.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="sch_lvbba_067">
      <sch:title>Procedureverloopmutatie verplicht bij soortKennisgeving="KennisgevingBesluittermijnen"</sch:title>
      <sch:rule context="data:KennisgevingMetadata">
         <sch:let name="KennisgevingBesluittermijnen"
                  value="data:soortKennisgeving = 'KennisgevingBesluittermijnen' or not(data:soortKennisgeving)"/>
         <sch:assert id="BHKV1067"
                     test="($KennisgevingBesluittermijnen and ../data:Procedureverloopmutatie and data:mededelingOver) or not($KennisgevingBesluittermijnen)"
                     role="fout">
        {"code": "BHKV1067", "expressie-id": "<sch:value-of select="../data:ExpressionIdentificatie/data:FRBRExpression"/>", "melding": "AanleveringKennisgeving \"<sch:value-of select="../data:ExpressionIdentificatie/data:FRBRExpression"/>\" heeft als data:soortKennisgeving=\"KennisgevingBesluittermijnen\" (of data:soortKennisgeving ontbreekt) maar heeft geen module data:Procedureverloopmutatie en het gegeven data:mededelingOver. Dit is niet toegestaan. Voeg data:Procedureverloopmutatie toe, of wijzig data:soortKennisgeving.", "ernst": "fout"},</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
