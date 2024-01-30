xquery version "1.0-ml";

module namespace local = "http://marklogic.com/schema-validator/lib/schematron-functions/mutaties";

import module namespace cons = "http://marklogic.com/schema-validator/lib/constants" at "/projects/opera/repos/opera/contexts/cds/lib/constants.xqy";
(:)import module namespace ophalen = "http://marklogic.com/schema-validator/lib/ophalen" at "/projects/opera/repos/opera/contexts/cds/lib/ophalen.xqy";
import module namespace queries = "http://marklogic.com/schema-validator/lib/queries" at "/projects/opera/repos/opera/contexts/cds/lib/queries.xqy";
import module namespace antwoorden = "http://marklogic.com/schema-validator/lib/antwoorden" at "/projects/opera/repos/opera/contexts/cds/lib/antwoorden.xqy";
import module namespace envelope = "http://marklogic.com/schema-validator/lib/envelope" at "/projects/opera/repos/opera/contexts/cds/lib/envelope.xqy";
:)
declare namespace opera = "http://koop.overheid.nl/apps/opera/";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "lvbb-schematron";

declare variable $wid-marker as xs:string := "##$$##";

(:~
 : Controleer of alle gevonden wIds in de RegelingMutatie aan bepaalde eisen voldoen
 :
 : @param $regeling-mutatie               element met de RegelingMutatie
 : @param $schemaversie                   versie van het schema
 :
 : @return                                foutmeldingen, indien leeg dan is alles ok
 :)
declare function local:controleer-wids-in-regeling-mutatie(
  $regeling-mutatie as element()?,
  $schemaversie as xs:string?
) as xs:string*
{
  if (fn:exists($regeling-mutatie))
  then

    let $was-versie := $regeling-mutatie/@was/fn:string()
    let $uri-versie := () (:)cts:uris((),(),queries:query-versie($was-versie)):)

    return
      if (fn:doc-available($uri-versie))
      then
        let $wids-was-versie :=
          for $deel in fn:doc($uri-versie)/opera:versie/opera:muteerbaar/element()/opera:deel
          return $deel/@id-element/fn:string()
        let $wordt-versie := $regeling-mutatie/@wordt/fn:string()

        (: maak de verschillende wid-groepen,
           deze worden gebruikt voor verschillende controles, hieronder vermeld als controles 2 t/m 10,
           dit zijn comtroles die vooraf kunnen worden gedaan,
           de 7 groepen staan als commentaar bij de functie 'maak-wid-groepen' hieronder
        :)
        let $element-wid-groepen := local:maak-wid-groepen($regeling-mutatie, $schemaversie)
        let $wids-mutatie-toevoegen := $element-wid-groepen/opera:wids-mutatie-toevoegen/opera:wid/fn:string()
        let $verwijder-mutaties := $element-wid-groepen/opera:wids-mutatie-verwijderen
        let $wids-mutatie-verwijderen := $verwijder-mutaties//opera:wid/fn:string()
        let $wids-mutatie-vervangen-juridisch := (
             $element-wid-groepen/opera:wids-mutatie-vervangen-juridisch/opera:wid/fn:string(),
             $element-wid-groepen/opera:wids-mutatie-vervangen-juridisch/opera:wat/opera:wid-wat/fn:string()
          )
        let $wids-mutatie-vervangen-revisie := (
            $element-wid-groepen/opera:wids-mutatie-vervangen-revisie/opera:wid/fn:string(),
            $element-wid-groepen/opera:wids-mutatie-vervangen-revisie/opera:wat/opera:wid-wat/fn:string()
          )
        let $wat-vervangen-verwijderen := $element-wid-groepen/opera:wids-wat-vervangen-verwijderen/opera:wat
        let $wids-wat-vervangen-verwijderen := $wat-vervangen-verwijderen/opera:wid-wat/fn:string()
        let $wids-wijzigactie-verwijderen := $element-wid-groepen/opera:wids-wijzigactie-verwijder/opera:wid/fn:string()
        let $wids-context-groepen := $element-wid-groepen/opera:wids-context/opera:context
        let $wids-context := $wids-context-groepen/opera:wid-context/fn:string()

        (: controles :)

        (: regel 1 : elke wid mag hooguit voorkomen binnen alle groepen - wordt gecontroleerd via STOP0027/28 in pr34 schematron :)

        (: regel 2 : elke wid in wids-mutatie-toevoegen mag niet voorkomen in wids-was-versie :)

        let $wids-toevoegen-en-was :=
          fn:distinct-values(
           fn:filter(function($a) { $a = $wids-was-versie}, $wids-mutatie-toevoegen)
          )
        let $melding-toevoegen-en-was :=
          if (fn:exists($wids-toevoegen-en-was))
          then () (:)antwoorden:get-error-message("OPERA-WIDS-TOEVOEGEN-EN-WAS",fn:string-join($wids-toevoegen-en-was,', '),$wordt-versie):)
          else ()

        (: regel 3 : elke wid in wids-mutatie-verwijderen moet voorkomen in wids-was-versie :)

        let $wids-verwijderen-en-niet-was :=
          fn:distinct-values(
           fn:filter(function($a) { fn:not($a = $wids-was-versie)}, $wids-mutatie-verwijderen)
          )
        let $melding-verwijderen-en-niet-was :=
          if (fn:exists($wids-verwijderen-en-niet-was))
          then () (:) antwoorden:get-error-message("OPERA-WIDS-VERWIJDEREN-EN-NIET-WAS",fn:string-join($wids-verwijderen-en-niet-was,', '),$wordt-versie):)
          else ()

        (: regel 4 en 4a : elke wid in wids-mutatie-vervangen-juridisch / wids-mutatie-juridisch-revisie moet voorkomen in wids-was-versie
                           de wids, die hier niet aan voldoen, vormen de impliciete-toevoegingen
                           en deze zijn niet toegestaan :)

        let $wids-impliciete-toevoegingen :=
          fn:distinct-values(
           fn:filter(function($a) { fn:not($a = $wids-was-versie)}, ($wids-mutatie-vervangen-juridisch, $wids-mutatie-vervangen-revisie))
          )
        let $melding-impliciete-toevoegingen :=
          if (fn:exists($wids-impliciete-toevoegingen))
          then () (:)antwoorden:get-error-message("OPERA-WIDS-IMPLICIETE-TOEVOEGINGEN",fn:string-join($wids-impliciete-toevoegingen,', '),$wordt-versie):)
          else ()

        (: zoek met de wids in wids-wat-vervangen-verwijderen en mbv het structuur document van de was-versie naar de oude
           samenstelling van de elementen, die vervangen of verwijderd gaan worden :)

        let $uri-structuur := () (:)cts:uris((),(),queries:query-structuur($was-versie)):)
        let $inhoud-structuur :=
          if (fn:doc-available($uri-structuur))
          then fn:doc($uri-structuur)/element()
          else ()

        let $map-was-versie-vervangen-en-verwijderen := map:map()

        let $_ :=
          for $wid in ($wids-wat-vervangen-verwijderen, $wids-wijzigactie-verwijderen)
          return map:put($map-was-versie-vervangen-en-verwijderen,$wid,$inhoud-structuur//element()[@wId = $wid]//@wId/fn:string())

        let $wids-was-versie-vervangen-en-verwijderen :=
          fn:distinct-values(
            for $key in map:keys($map-was-versie-vervangen-en-verwijderen)
            return map:get($map-was-versie-vervangen-en-verwijderen,$key)
          )

        (: regel 5 : elke wid in wids-was-versie-vervangen-en-verwijderen moet voorkomen in wids-mutatie-verwijderen of
                     wids-mutatie-vervangen-juridisch of wids-mutatie-vervangen-revisie maar niet in wids-mutatie-toevoegen.
                     de wids, die hier niet aan voldoen, vormen de impliciete verwijdering en deze zijn niet toegestaan :)

        let $wids-impliciete-verwijderingen :=
          fn:distinct-values(
           fn:filter(function($a)
             {fn:not($a = ($wids-mutatie-toevoegen, $wids-mutatie-verwijderen, $wids-mutatie-vervangen-juridisch, $wids-mutatie-vervangen-revisie))},
             $wids-was-versie-vervangen-en-verwijderen)
          )
        let $melding-impliciete-verwijderingen :=
          if (fn:exists($wids-impliciete-verwijderingen))
          then () (:)antwoorden:get-error-message("OPERA-WIDS-IMPLICIETE-VERWIJDERINGEN",fn:string-join($wids-impliciete-verwijderingen,', '),$wordt-versie):)
          else ()

        (: regel 6 : voor een vervang of verwijder mutatie moet de wid bij attribuut 'wat' gelijk zijn aan de wid van het te verrvangen /
                     te verwijderen element :)

        let $elements-wid-wat-ongelijk-wid-child :=
          fn:filter(function($a)
             {fn:exists($a/opera:wid-child/text()) and fn:not($a/opera:wid-wat = $a/opera:wid-child)},$wat-vervangen-verwijderen)

        let $meldingen-wid-wat-ongelijk-wid-child :=
          for $element in $elements-wid-wat-ongelijk-wid-child
          return () (:)antwoorden:get-error-message("OPERA-WIDS-ONGELIJK",
            ($wordt-versie, $element/opera:wid-wat/fn:string(), $element/opera:wid-child/fn:string()),$wordt-versie):)

        (: regel 7 : elke context moet voorkomen in de wids-was-versie of wids-mutatie-toevoegen :)

        let $wids-niet-bestaande-contexts :=
          fn:distinct-values(
           fn:filter(function($a)
             {fn:not($a = ($wids-was-versie,$wids-mutatie-toevoegen))},$wids-context)
         )
        let $melding-niet-bestaande-contexts :=
          if (fn:exists($wids-niet-bestaande-contexts))
          then () (:)antwoorden:get-error-message("OPERA-WIDS-NIET-BESTAANDE-CONTEXTS",fn:string-join($wids-niet-bestaande-contexts,', '),$wordt-versie):)
          else ()

        (: regel 8 : als in een verwijder-mutatie / element met wijzigactie = 'verwijder' kinderen voorkomen dan moet al deze kinderen
                     ook al voorkomen in de was-versie bij dat desbtreffende element :)

        let $meldingen-onjuist-in-verwijder :=
          for $verwijder-mutatie-parent in $verwijder-mutaties/opera:parent
          let $wid-parent := $verwijder-mutatie-parent/opera:wid/fn:string()
          let $wids-children := $verwijder-mutatie-parent/opera:children/opera:wid/fn:string()
          let $wids-onjuist-in-verwijder :=
            fn:filter(function($a)
              {fn:not($a = map:get($map-was-versie-vervangen-en-verwijderen,$wid-parent))},$wids-children)
          return
            if (fn:exists($wids-onjuist-in-verwijder))
            then () (:)antwoorden:get-error-message("OPERA-WIDS-ONJUIST-IN-VERWIJDER",($wid-parent,fn:string-join($wids-onjuist-in-verwijder,', ')),$wordt-versie):)
            else ()

        (: regel 9 : als in een vervang-mutatie verwijder opties staan (wijzigactie = 'verwijderContainer' / 'verwijder')  dan moet in de
                     was-versie dit element een kind zijn van het element dat vervangen wordt :)

        let $meldingen-onjuiste-parent-verwijder :=
          for $verwijder-mutatie-parent in $verwijder-mutaties/opera:parent[not(empty(opera:wid-ancestor))]
          let $wid-parent := $verwijder-mutatie-parent/opera:wid/fn:string()
          let $wid-ancestor := $verwijder-mutatie-parent/opera:wid-ancestor/fn:string()
          let $wids-onjuiste-parent-verwijder :=
            fn:filter(function($a)
              {fn:not($a = map:get($map-was-versie-vervangen-en-verwijderen,$wid-ancestor))},$wid-parent)
          return
            if (fn:exists($wids-onjuiste-parent-verwijder))
            then () (:)antwoorden:get-error-message("OPERA-WIDS-ONJUIST-IN-VERWIJDER",($wid-ancestor,$wid-parent),$wordt-versie):)
            else ()

        (:  regel 10 : als een bepaalde wId als context wordt gebruikt in een Vervang / VoegToe mutatie dan mag deze
                       wId niet meer voorkomen in een vervolg mutatie; dat mag sowieso niet (bij positie = leeg -> kindVan)
                       of niet als child van een te muteren element (bij positie = volgtOp / komtVoor);
                       als dat wel zo is dan houdt dat in dat wIds, die vervangen / toegevoegd worden, in de uiteindelijke
                       wordt-versie geen parent meer hebben :)

        let $meldingen-wids-zonder-parent-in-wordt :=
          let $wids-zonder-parent-in-wordt :=
            fn:distinct-values(
              for $wid-context-groep in $wids-context-groepen
              where (xs:boolean($wid-context-groep/opera:in-vervolg-mutatie/string()))
              return ($wid-context-groep/opera:wids/opera:wid/string())
            )
          return
            if (fn:exists($wids-zonder-parent-in-wordt))
            then () (:)antwoorden:get-error-message("OPERA-WIDS-GEEN-PARENT-IN-WORDT",$wids-zonder-parent-in-wordt,$wordt-versie):)
            else ()

        (: regel 11 : de wid van een Vervang-mutatie / VoegToe-mutatie mag niet gelijk zijn aan de context, dit zou je een
                      toevoeging / verplaatsing tov jezelf inhouden :)

        let $meldingen-wat-gelijk-aan-context :=
          let $wids-gelijk-aan-context :=
            for $wid-context-groep in $wids-context-groepen
            let $wid-context := $wid-context-groep/opera:wid-context/fn:string()
            for $wid-mutatie in $wid-context-groep/opera:wids/opera:wid/fn:string()
            where ($wid-mutatie = $wid-context)
            return $wid-mutatie
          return
            if (fn:exists($wids-gelijk-aan-context))
            then () (:)antwoorden:get-error-message("OPERA-WIDS-GELIJK-AAN-CONTEXT",$wids-gelijk-aan-context,$wordt-versie):)
            else ()

        (: regel 12 : Als er een Vervang-mutatie is van een ouder en een Vervang-mutatie van een kind
                      (ouder-kind relatie geldt in de was-versie) dan moet de Vervang-mutatie van het kind een
                      context hebben; als dat niet zo is dan is er voor dit kind geen plaats te bepalen in de wordt-versie :)

        (: $map-was-versie-vervangen-en-verwijderen heeft als key de wId van een Vervang-mutatie of Verwijder-mutatie
           en als waarde deze wId plus alle ondrliggende kinderen volgens de was-versie :)

        let $wids-kinderen-in-was-versie :=
          for $key in map:keys($map-was-versie-vervangen-en-verwijderen)
          let $waardes-overige-keys :=
            for $overige-key in map:keys($map-was-versie-vervangen-en-verwijderen)
            where (fn:not($overige-key = $key))
            return map:get($map-was-versie-vervangen-en-verwijderen,$overige-key)
          where ($key = $waardes-overige-keys)
          return $key

        let $wids-vervang-zonder-context :=  $element-wid-groepen/opera:wids-vervang-zonder-context/opera:wid/fn:string()

        let $meldingen-wids-zonder-plaats-in-wordt-versie :=
          let $wids-zonder-plaats-in-wordt-versie :=
            fn:filter(function($a)
              {$a = $wids-vervang-zonder-context},$wids-kinderen-in-was-versie)
          return
            if (fn:exists($wids-zonder-plaats-in-wordt-versie))
            then () (: )antwoorden:get-error-message("OPERA-WIDS-ZONDER-PLAATS-IN-WORDT",$wids-zonder-plaats-in-wordt-versie,$wordt-versie):)
            else ()

        return (
           $melding-toevoegen-en-was,
           $melding-verwijderen-en-niet-was,
           $melding-impliciete-toevoegingen,
           $melding-impliciete-verwijderingen,
           $meldingen-wid-wat-ongelijk-wid-child,
           $melding-niet-bestaande-contexts,
           $meldingen-onjuist-in-verwijder,
           $meldingen-onjuiste-parent-verwijder,
           $meldingen-wids-zonder-parent-in-wordt,
           $meldingen-wat-gelijk-aan-context,
           $meldingen-wids-zonder-plaats-in-wordt-versie
        )
      else ()
  else ()
};

(:~
 : Maak een element met daarbinnen de wid-groepen binnen de RegelingMutatie
 : Er zijn de volgende groepen:
 : 1. wids-mutatie-toevoegen           : alle wIds in een VoegToe (ook kinderen) + alle wIds in een Vervang met nieuweContainer +
 :                                       alle wIds in een Vervang (ook kinderen) met wijzigactie = 'voegtoe'
 : 2. wids-mutatie-verwijderen         : alle wIds in een Verwijder (ook kinderen) + alle wIds in een Vervang met verwijderContainer +
 :                                       alle wIds in een Vervang (ook kinderen) met wijzigactie = 'verwijder'
 : 3. wids-mutatie-vervangen-juridisch : alle wat in een VervangKop + alle wIds in een Vervang met leeg attribuut 'revisie' of 'revisie=0'
 :                                       (ook kinderen) waarbij de wId niet binnen wIds-mutatie-toevoegen of wIds-mutatie-verwijderen valt
 : 4. wids-mutatie-vervangen-revisie   : alle wIds in een Vervang met leeg attribuut 'revisie=1'
 :                                       (ook kinderen) waarbij de wId niet binnen wIds-mutatie-toevoegen of wIds-mutatie-verwijderen valt
 : 5. wids-wat-vervangen-verwijderen   : wids van elementen, die als 'wat' in een Vervang of Verwijder mutatie staan; deze elementen
 :                                       kunnen in de mutatie kinderen hebben (groep-a); deze 'wat' worden gebruikt om vanuit de
 :                                       bestaande was-versie ook de kinderen op te halen (groep-b); alle kinderen, die in groep-a
 :                                       niet expliciet toegevoegd worden, moeten voorkomen in groep-b
 : 6. wids-wijzigactie-verwijder       : wids van elementen, die in een Vervang een wijzigactie 'verwijdet' hebben; deze elementen
 :                                       kunnen in de mutatie kinderen hebben (groep-a); deze 'wat' worden gebruikt om vanuit de
 :                                       bestaande was-versie ook de kinderen op te halen (groep-b); alle kinderen uit groep-a
 :                                       moeten voorkomen in groep-b
 : 7. wids-context                     : wids, die als context gebruikt worden in een VoegToe of een Vervang
 : 8. wids-vervang-zonder-context      : alle wids in en Vervang0opdracht zonder context (geen kinderen)
 :
 : @param $regeling-mutatie               element met de RegelingMutatie
 : @param $schemaversie                   versie van het schema
 :
 : @return                                element met als kinderen de diverse groepen
 :)
declare private function local:maak-wid-groepen(
  $regeling-mutatie as element(),
  $schemaversie as xs:string
) as element()?
{
  let $from := "regeling-mutatie"
  let $to := "wid-groepen"
  let $map-parameters := map:map()
  => map:with("muteerbare-elementen",$cons:muteerbare-elementen)
  return () (:)ophalen:uitvoeren-transformatieplan($regeling-mutatie, $from, $to, $map-parameters, $schemaversie):)
};

(:~
 : Haal de inhoud van het besluit op waarin een gegeven regelingversie is vastgesteld.
 : Dit kan leeg zijn omdat niet elke regelingversie via een besluit wordt vastgesteld.
 :
 : @param $doc-info                       document informatie (met o.a. uri, oin, idlevering)
 :
 : @return                                inhoud van het vaststellende besluit (of leeg)
 :)
declare function local:get-content-besluit-bij-versie(
  $doc-info as map:map?
) as element()?
{
  if (fn:empty($doc-info))
  then ()
  else
    if (map:get($doc-info,"root") eq "Consolidaties")
    then () (: geen besluit :)
    else
      let $uri := map:get($doc-info,"uri")
      return fn:doc($uri)/element()
};
