xquery version "1.0-ml";

module namespace local = "http://marklogic.com/schema-validator/lib/work/informatieobject/metadata";

import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";
import module namespace qry = "http://marklogic.com/schema-validator/lib/aanlevering/query-utilities" at "/lib/aanlevering/query-utilities.xqy";

declare namespace opera = "http://koop.overheid.nl/apps/opera/";

declare option xdmp:mapping "false";

(:~
 : Ga na of bepaalde gegevens, die opgeslagen zijn bij het informatie-object (werk-nivo), overeenkomen met de InformatieobjectMetadata,
 : die wordt aangeleverd. Deze controle hoeft niet als er nog geen informatie-object (werk-nivo) bekend is of als de aangeboden
 : InformatieobjectMetadata bij een ontwerp besluit hoort en binnen de informatie-object (werk-nivo) reeds definitieve expressie bekend zijn.
 :
 : @param $join-id-werk                   join identificatie van een informatie-object (werk-nivo)
 : @param $doc-info                       map met daarin document informatie (oa. oin en idlevering)
 : @param $eindverantwoordelijke          eindverantwoordelijke binnen de InformatieobjectMetadata van het aangeboden io
 : @param $formaat-informatieobject       formaat-informatieobject binnen de InformatieobjectMetadata van het aangeboden io
 : @param $maker                          maker binnen de InformatieobjectMetadata van het aangeboden io
 : @param $naam-informatieobject          naam-informatieobject binnen de InformatieobjectMetadata van het aangeboden io
 : @param $opvolging                      opvolging binnen de InformatieobjectMetadata van het aangeboden io
 : @param $publicatieinstructie           publicatieinstructie binnen de InformatieobjectMetadata van het aangeboden io
 :
 : @return                                foutmeldingen
 :)
declare function local:check-metadata-ok(
  $join-id-werk as xs:string,
  $doc-info as map:map?,
  $eindverantwoordelijke as xs:string,
  $formaat-informatieobject as xs:string,
  $maker as xs:string,
  $officiele-titel as xs:string,
  $opvolging as xs:string?,
  $publicatieinstructie as xs:string
) as xs:string*
{
  (: vanuit de inhoud van het informatie-object het besluit ophalen om daarmee vast te kunnen stellen of het om
     een ontwerp besluit of een definitief besluit gaat :)
  let $oin := map:get($doc-info,"oin")
  let $idlevering := map:get($doc-info,"idlevering")
  let $uri-opdracht-xml := cts:uris((),(),qry:aanlevering-bestand($oin, $idlevering, $const:opdracht-xml))
  let $content-document := ()(:core:get-content-document-from-opdracht($uri-opdracht-xml):)

  let $is-ontwerp :=
    if (fn:empty($content-document))
    then fn:false() (: aangeleverd via publiceerCio / publiceerGio = definitief :)
    else fn:false()(:)ophalen:check-besluit-is-ontwerp($content-document):)

  return
    (:)if (local:controle-metadata-noodzakelijk($join-id-werk, $is-ontwerp))
    then
      let $uri-io-werk := cts:uris((),(),queries:query-informatie-object-werk($join-id-werk))
      let $header-io-werk := envelope:get-headers-from-envelope(fn:doc($uri-io-werk)/element())
      return
        (
          if (fn:not($header-io-werk/opera:eindverantwoordelijke/fn:string() = $eindverantwoordelijke))
          then antwoorden:get-error-message("OPERA-WIJZ-IO-META-NIET-TOEGESTAAN", ("eindverantwoordelijke"), $join-id-werk)
          else (),
          if (fn:not($header-io-werk/opera:formaat-informatieobject/fn:string() = $formaat-informatieobject))
          then antwoorden:get-error-message("OPERA-WIJZ-IO-META-NIET-TOEGESTAAN", ("formaatInformatieobject"), $join-id-werk)
          else (),
          if (fn:not($header-io-werk/opera:maker/fn:string() = $maker))
          then antwoorden:get-error-message("OPERA-WIJZ-IO-META-NIET-TOEGESTAAN", ("maker"), $join-id-werk)
          else (),
          if (fn:not($header-io-werk/opera:officiele-titel/fn:string() = $officiele-titel))
          then antwoorden:get-error-message("OPERA-WIJZ-IO-META-NIET-TOEGESTAAN", ("officieleTitel"), $join-id-werk)
          else (),
          if (fn:exists($header-io-werk/opera:opvolging))
          then
            if (fn:empty($opvolging) or
                fn:not(fn:string-join($header-io-werk/opera:opvolging/opera:opvolger-van/fn:string(),',') = $opvolging))
            then antwoorden:get-error-message("OPERA-WIJZ-IO-META-NIET-TOEGESTAAN", ("opvolging"), $join-id-werk)
            else ()
          else (),
          if (fn:not($header-io-werk/opera:publicatieinstructie/fn:string() = $publicatieinstructie))
          then antwoorden:get-error-message("OPERA-WIJZ-IO-META-NIET-TOEGESTAAN", ("publicatieinstructie"), $join-id-werk)
          else ()
        )
    else :)()
};