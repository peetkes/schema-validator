xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/schematron-functions/intern";

import module namespace constants = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";
(:)import module namespace queries = "http://marklogic.com/schema-validator/lib/queries" at "/projects/opera/repos/opera/contexts/cds/lib/queries.xqy";
import module namespace versie = "http://marklogic.com/schema-validator/lib/versie" at "/projects/opera/repos/opera/contexts/cds/lib/versie.xqy";
import module namespace besluit = "http://marklogic.com/schema-validator/lib/besluit" at "/projects/opera/repos/opera/contexts/cds/lib/besluit.xqy";
import module namespace envelope = "http://marklogic.com/schema-validator/lib/envelope" at "/projects/opera/repos/opera/contexts/cds/lib/envelope.xqy";
import module namespace tpods = "http://marklogic.com/schema-validator/lib/tpods" at "/projects/opera/repos/opera/contexts/cds/lib/tpods.xqy";
:)
declare namespace opera = "http://koop.overheid.nl/apps/opera/";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "lvbb-schematron";

declare variable $werk-is-gepubliceerd as xs:integer := 1;
declare variable $werk-is-niet-gepubliceerd as xs:integer := 2;
declare variable $zelfde-aanlevering as xs:integer := 3;
declare variable $werk-bestaat-niet as xs:integer := 4;

(:~
 : Checkt of het besluit dat deze regelingversie vaststelde gepubliceerd is, of indien het een bruidschatversie betreft.
 : Als besluit dat deze versie heeft vastgesteld is gepubliceerd, heeft het besluit een pubicatie datum
 : Als de versie is ingelegd via de bruidschat, dan heeft de versie een consolidatie-datum-bekend-op en is de maker van de regeling een ministerie
 :
 : @param $akn-expressie    akn id van de regeling-versie (was-versie van mutatie)
 :
 : @return             integer (1= werk is-gepubliceerd, 2=werk-is-niet-gepubliceerd)
 :)
declare function local:check-besluit-was-gepubliceerd(
  $akn-expressie as xs:string
) as xs:integer
{
  xdmp:trace($TRACE-ID, xdmp:transaction() || "::check-besluit-was-gepubliceerd::" || $akn-expressie),
  let $versie := ()
  return
    if (fn:exists($versie))
    then
      let $oin := $versie//opera:oin
      let $idlevering := $versie//opera:id-levering
      return local:check-is-gepubliceerd($oin, $idlevering, "besluit-was", $akn-expressie)
    else (
      xdmp:trace($TRACE-ID, xdmp:transaction() || "::geen versie aanwezig voor::" || $akn-expressie),
      $werk-bestaat-niet
    )
};

(:~
 : Checkt of het besluit dat deze regeling gepubliceerd is, of indien het een bruidschat regeling betreft.
 : Als besluit dat deze regeling heeft vastgesteld is gepubliceerd, heeft het besluit een publicatie datum
 : Als de regeling is ingelegd via de bruidschat, dan heeft de versie een consolidatie-datum-bekend-op en is de maker van de regeling een ministerie
 :
 : @param $work-id     werk identifier van de regeling waarvoor gecheckt moet worden of besluit gepubliceerd is
 :
 : @return             integer (1= werk is-gepubliceerd, 2=werk-is-niet-gepubliceerd, 3=in-zelfde-aanlevering, 4=werk-bestaat-niet)
 :)
declare function local:check-vaststellend-besluit-is-gepubliceerd(
  $work-id as xs:string
) as xs:integer
{
  local:check-vaststellend-besluit-is-gepubliceerd($work-id, ())
};

(:~
 : Checkt of het besluit dat regeling/informatieobject of geboorteregeling van een informatie-object vaststelt gepubliceerd is.
 : Indien het een bruidschat regeling betreft is deze ALTIJD gepubliceerd.
 : Indien de bron een consolidatie is, wordt deze altijd als gepubliceerd beschouwd.
 : Als besluit dat deze regeling heeft vastgesteld is gepubliceerd, heeft het besluit een publicatie datum
 : Als de geboorteregeling van het informatieobject niet bestaat moet foutmelding LVBB3510 teruggegeven worden
 :
 : @param $work-id     akn-id van regeling of join-id van informatie-object waarvoor gecheckt moet worden of besluit dat regeling vaststelt of
 : @param $doc-info    map met daarin document informatie (oa. doc root, parent, work, expression, oin en idlevering)
 :
 : @return             integer (1= werk is-gepubliceerd, 2=werk-is-niet-gepubliceerd, 3=in-zelfde-aanlevering, 4=werk-bestaat-niet)
 :)
declare function local:check-vaststellend-besluit-is-gepubliceerd(
  $work-id as xs:string,
  $doc-info as map:map?
) as xs:integer
{
  xdmp:trace($TRACE-ID, xdmp:transaction() || "::check-vaststellend-besluit-is-gepubliceerd::work-id=" ||
    $work-id || "::" || xdmp:quote($doc-info)),
  (: check eerst of in de database al een regeling of informatie-object met work-id bestaat :)

  let $uri-instrument := () (: check database :)
  let $_ := xdmp:trace($TRACE-ID, xdmp:transaction() || "::uri-instrument=" || $uri-instrument)
  return
    if (fn:empty(fn:doc($uri-instrument)))
    then
      if (fn:exists($doc-info))
      then (
        if (map:get($doc-info,"root") eq "Consolidaties")
        then (   (: instrument via Consolidatie? :)
          xdmp:trace($TRACE-ID, xdmp:transaction() || "::aangeleverd via Consolidatie"),
          $werk-is-gepubliceerd
        )
        else (  (: vaststellende instrument in zelfde aanlevering? :)
          xdmp:trace($TRACE-ID, xdmp:transaction() || "::vaststellende instrument in zelfde aanlevering?::" || fn:exists($doc-info)),
          let $instrument-info := local:get-doc-info-for-id(map:get($doc-info, "parent"), $work-id, map:get($doc-info, "work"), map:get($doc-info,"expression"))
          return (
            xdmp:trace($TRACE-ID, xdmp:transaction() || "::instrument-info bestaat?::" || fn:exists($instrument-info)),
            if (map:get($instrument-info, "oin") eq map:get($doc-info,"oin") and
                map:get($instrument-info, "idlevering") eq map:get($doc-info,"idlevering"))
            then (
              xdmp:trace($TRACE-ID, xdmp:transaction() || "::ZELFDE AANLEVERING::" || map:get($instrument-info, "root")),
              $zelfde-aanlevering
            )
            else (
              xdmp:trace($TRACE-ID, xdmp:transaction() || "::NIET ZELFDE AANLEVERING::" || map:get($instrument-info, "root")),
              $werk-bestaat-niet
            )
          )
        )
      )
      else (
          xdmp:trace($TRACE-ID, xdmp:transaction() || "::geen doc-info bij lege uri-instrument::" || $work-id),
          $werk-bestaat-niet
      )
    else (
      xdmp:trace($TRACE-ID, xdmp:transaction() || "::Found instrument!::" || $uri-instrument ),
      let $instrument := fn:doc($uri-instrument)/element()
      let $oin := "dummy" (:)envelope:get-headers-element-from-envelope($instrument, "oin")/fn:string():)
      let $idlevering := "dummy" (:)(envelope:get-headers-element-from-envelope($instrument, "idlevering"),envelope:get-headers-element-from-envelope($instrument, "id-levering"))[1]/fn:string():)
      return local:check-is-gepubliceerd($oin, $idlevering, "vaststellend-besluit", $work-id)
    )
};

(:~
 : Deze functie haalt wat informatie op voor een bestand uit de aanlevering met de opgegeven identifier
 : Dit kan ofwel een work-id ofwel een expression-id zijn.
 :
 : @param $parent     fully qualified naam van de parent
 : @param $identifier identifier voor docinfo
 : @param $work       fully qualified naam van het frbrwork
 : @param $expression fully qualified naam van de frbrexpression
 : @return            map met daarin uri, oin en idlevering van de huidige aanlevering, parent work en expression of leeg als niets gevonden
 :)
declare function local:get-doc-info-for-id(
  $parent as xs:QName,
  $identifier as xs:string,
  $work as xs:QName,
  $expression as xs:QName?
) as map:map
{
  xdmp:trace($TRACE-ID, xdmp:transaction() || "::get-doc-info-for-id::" || $identifier || "::" || $parent || "::" || $work || "::" || $expression),
  let $query := cts:and-query((
    cts:collection-query($constants:collection-aanlevering-bestanden),
    cts:element-query(
      $parent,
      cts:or-query((
        cts:element-value-query($work, $identifier),
        if (fn:exists($expression)) then cts:element-value-query($expression, $identifier) else ()
      ))
    )
  ))
  let $uri := cts:uris((),("limit=1"), $query)
  return (
    xdmp:trace($TRACE-ID, xdmp:transaction() || "::" || xdmp:quote(<x>{$query}</x>/*)),
    xdmp:trace($TRACE-ID, xdmp:transaction() || "::uri::" || $uri),
    if (fn:empty($uri))
    then (
      xdmp:trace($TRACE-ID, xdmp:transaction() || "::get-doc-info-for-id::doc-uri::empty" || $uri || " took " || xdmp:elapsed-time()),
      map:map()
    )
    else (
      let $collections := xdmp:document-get-collections($uri)
      let $map := map:map()
      =>map:with("uri", $uri)
      =>map:with("root", fn:doc($uri)/*/fn:local-name())
      =>map:with("parent", $parent)
      =>map:with("work", $work)
      =>map:with("expression", $expression)
      =>map:with("oin",
        fn:filter(function($a) { fn:starts-with($a, $constants:prefix-collection-oin) }, $collections)
        =>fn:substring-after($constants:prefix-collection-oin))
      =>map:with("idlevering",
        fn:filter(function($a) { fn:starts-with($a, $constants:prefix-collection-idlevering) }, $collections)
        =>fn:substring-after($constants:prefix-collection-idlevering))
      return (
        $map,
        xdmp:trace($TRACE-ID, xdmp:transaction() || "::" || xdmp:quote($map)),
        xdmp:trace($TRACE-ID, xdmp:transaction() || "::get-doc-uri-for-id::doc-uri::found::" || $uri || " took " || xdmp:elapsed-time())
      )
    )
  )
};

(:~
 : Deze functie haalt wat informatie op voor een bestand uit de aanlevering met de opgegeven identifier
 : Dit kan ofwel een work-id ofwel een expression-id zijn.
 :
 : @param $parent     fully qualified naam van de parent
 : @param $identifier identifier voor docinfo
 : @param $work       fully qualified naam van het frbrwork
 : @return            map met daarin uri, oin en idlevering van de huidige aanlevering, parent work of leeg als niets gevonden
 :)
declare function local:get-doc-info-for-id(
  $parent as xs:QName,
  $identifier as xs:string,
  $work as xs:QName
) as map:map
{
  local:get-doc-info-for-id($parent,$identifier,$work,())
};

(:~
 : Deze functie checkt of het besluit horende bij oin/idlevering bestaat (geen bruidschat) en of deze een publicatiedatum heeft
 : Als het besluit niet bestaat wordt uitgegaan van bruidschat en dus gepubliceerd verondersteld.
 :
 : @param $oin          oin van de aanlevering
 : @param $idlevering   id van de aanlevering
 : @param $type         check was van de versie of vaststellend besluit van de regeling
 : @param $id           id van de versie of de regeling
 :)
declare private function local:check-is-gepubliceerd(
  $oin as xs:string,
  $idlevering as xs:string,
  $type as xs:string,
  $id as xs:string
) as xs:integer
{
  xdmp:trace($TRACE-ID, fn:concat(xdmp:transaction(), "::check-", $type, "-is-gepubliceerd::", $id)),
  let $besluit-meta := () (:)besluit:haal-header-besluit($oin, $idlevering):)
  let $publicatie-datum := $besluit-meta//opera:publicatie-datum
  return
    if (fn:empty($besluit-meta) or fn:exists($publicatie-datum))
    then (
      xdmp:trace($TRACE-ID, fn:concat(xdmp:transaction(), "::bruidschat of gepubliceerd::", $publicatie-datum)),
      $werk-is-gepubliceerd
    ) else (
      xdmp:trace($TRACE-ID, fn:concat(xdmp:transaction(), "::niet-gepubliceerd")),
      $werk-is-niet-gepubliceerd
    )
};

(:~
 : Deze functie haalt de soort opdracht op vanuit de opgegeven identifier binnen een aanlevering
 : Dit kan ofwel een work-id ofwel een expression-id zijn.
 :
 : @param $parent      fully qualified naam van de parent
 : @param $work        fully qualified naam van het frbrwork
 : @param $identifier  identifier voor docinfo
 :
 : @return             soort opdracht vanuit de bijgehorende opdracht.xml
 :)
declare function local:get-soort-opdracht(
  $parent as xs:QName,
  $work as xs:QName,
  $identifier as xs:string
) as xs:string?
{
  let $map-doc-info := local:get-doc-info-for-id($parent,$identifier,$work)
  let $oin := map:get($map-doc-info,"oin")
  let $idlevering := map:get($map-doc-info,"idlevering")
  let $uri-opdracht := () (:)cts:uris((),(),queries:query-regisseur-specifiek-bestand($oin,$idlevering,$constants:suffix-regisseur-opdracht)):)
  return
    if (fn:exists($uri-opdracht))
    then fn:local-name(fn:doc($uri-opdracht)/element())
    else ()
};

(:~
 : Deze functie checkt of de combinatie eindverantwoordelijk besluit met de type regeling en de soort regeling van de regelingen,
 : die vastgesteld en gemuteerd worden (tpod controles)
 :
 : @param $id-besluit                identificatie van het besluit
 : @param $eindverantwoordelijke     eindverantwoordelijke van een besluit
 : @param $type-regeling             type regeling van de regeling, die vastgesteld of gebruikt wordt (b.v. RegelingCompact)
 :                                   dit staat bij een initiele aanlevering in de RegelingMetadata, bij een mutatie moet dit
 :                                   opgehaald worden vanuit de opgeslagen regeling
 : @param $soort-regeling            soort regeling van de regeling, die vastgesteld of gebruikt wordt (b.v. code voor Omgevingsplan)
 :                                   dit staat bij een initiele aanlevering in de RegelingMetadata, bij een mutatie moet dit
 :                                   opgehaald worden vanuit de opgeslagen regeling
 : @param $id-regeling               akn-identifiactie van de regeling, wordt gebruikt als RegelingMetadata niet voorkomt in het besluit
 :
 : @return                           foutmeldingen (bij leeg is alles ok)
 :)
declare function local:controleer-tpods(
  $id-besluit as xs:string,
  $eindverantwoordelijke as xs:string?,
  $type-regeling as xs:string?,
  $soort-regeling as xs:string?,
  $id-regeling as xs:string?
) as xs:string*
{
  xdmp:trace($TRACE-ID, xdmp:transaction() || "::controleer-tpods::" || $eindverantwoordelijke || "::" ||
    $type-regeling || "::" || $soort-regeling || "::" || $id-regeling),
  ()
  (:)tpods:controleer-tpods($id-besluit,$eindverantwoordelijke,$type-regeling,$soort-regeling,$id-regeling):)
};

(:~
 : Ga op zoek naar de een regeling, die binnen een besluit wordt vastgesteld of wordt ingetrokken
 : Het eerste voorkomen hiervan is genoeg
 :
 : @param $akn-id-besluit                 akn id van het besluit
 :
 : @return                                id van een regeling van de regelingversie, die vastgesteld of ingetrokken wordt in het besluit
 :)
declare function local:zoek-id-regeling-bij-besluit(
  $akn-id-besluit as xs:string?
) as xs:string?
{
  xdmp:trace($TRACE-ID, xdmp:transaction() || "::zoek-id-regeling-bij-besluit::" || $akn-id-besluit),

  if (fn:exists($akn-id-besluit))
  then
    let $uri-besluit := () (:) besluit:zoek-besluit-obv-akn($akn-id-besluit):)
    return
      if (fn:exists($uri-besluit))
      then
        let $header-besluit := <opera:dummy/>(:)envelope:get-headers-from-envelope(fn:doc($uri-besluit)/element()):)
        let $oin := $header-besluit/opera:oin/fn:string()
        let $idlevering := $header-besluit/opera:idlevering/fn:string()

        (: vastgestelde regelingversie :)
        let $uri-versie := () (:)cts:uris((),"limit=1",queries:query-opdracht-versies($oin,$idlevering)):)
        let $uri-versie :=
          if (fn:exists($uri-versie))
          then $uri-versie
          else
            (: ingetrokken regelingversies :)
            let $query := cts:and-query((
              cts:collection-query($constants:collection-versie),
              cts:element-query(xs:QName("opera:alle-doelen"),
            cts:element-query(xs:QName("opera:doel"),
                cts:and-query((
                    cts:element-attribute-value-query(xs:QName("opera:doel"), xs:QName("oin"), $oin),
                    cts:element-attribute-value-query(xs:QName("opera:doel"), xs:QName("id-levering"), $idlevering),
                    cts:element-attribute-value-query(xs:QName("opera:doel"), xs:QName("intrekking"), "true")
                  ))
                )
              )
            ))
            return cts:uris((),"limit=1",$query)
        return
          if (fn:exists($uri-versie))
          then fn:doc($uri-versie)/opera:versie/opera:metadata/opera:regeling-id/fn:string()
          else ()
    else ()
  else ()
};
