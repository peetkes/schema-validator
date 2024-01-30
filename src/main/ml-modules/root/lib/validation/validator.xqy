xquery version "1.0-ml";
(: Copyright (c) 2020 MarkLogic Corporation :)
module namespace local = "http://marklogic.com/schema-validator/lib/validation/validator";

import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";
import module namespace helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";
import module namespace xsd-validator="http://marklogic.com/schema-validator/lib/validation/schema/validator" at "/lib/validation/schema/validator.xqy";
import module namespace sch-validator="http://marklogic.com/schema-validator/lib/validation/schematron/schematron-validator" at "/lib/validation/schematron/schematron-validator.xqy";

declare namespace schemata = "https://standaarden.overheid.nl/stop/imop/schemata/";
declare namespace opera = "http:koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "sv-validation";

(:~
 : Function: validate-xml
 : deze functie voert een validatie uit op het aangeboden document, rekening houdend met het feit of het document al in envelope structuur zit.
 : Er worden twee typen validatie uitgevoerd.
 : 1ste type is een reguliere schema (xsd) validatie. Er wordt bepaald met welke versie van een schema het document is aangemaakt.
 : Op basis van versie en namespace van het root element wordt het juiste schema uit de schemas database geselecteerd en wordt de xsd validatie uitgevoerd.
 : 2de type is schematron validatie indien nodig. Vanuit de versieoverzichten in de database wordt bepaald welke schematron validaties uitgevoerd moeten worden.
 : op basis van de metadata van het schema waarmee de xsd validatie is uitgevoerd kan bepa
 :
 :
 : @param
 : @result
 :)
 declare function local:validate-xml(
  $uri as xs:string
) as json:object*
{
  xdmp:trace($TRACE-ID, ("validate-xml", "URI", $uri)),
  let $is-envelopped := if (fn:node-name(fn:doc($uri)/node()) eq xs:QName("opera:envelope")) then fn:true() else fn:false()
  return (
    if ($is-envelopped)
    then (
      let $node := document { fn:doc($uri)/descendant-or-self::opera:instance/node() }/node()
      return local:validate-by-node($node)
    )
    else local:validate-by-uri($uri)
  )
};

declare function local:validate-by-uri(
  $uri as xs:string
) as json:object*
{
  xdmp:trace($TRACE-ID, ("validate-by-uri", $uri)),
  let $node := fn:doc($uri)/node()
  let $schema := helper:get-schema-for-node($node)
  let $schema-report := xsd-validator:validate-node(map:get($schema, "namespace"), map:get($schema, "uri"), $node)
  let $schematrons := helper:get-schematrons-for-node($node, map:get($schema, "uri"))
  let $schematron-reports := $schematrons ! sch-validator:validate-node($node, ., ())
  let $result := json:object()
  =>map:with("schema", map:get($schema-report, "schema"))
  return (
    if (fn:exists($schematron-reports))
    then map:put($result,"schematron", $schematron-reports ! map:get(., "schematron"))
    else (),
    $result
  )
};

declare function local:validate-by-node(
  $node as node()
) as json:object*
{
  xdmp:trace($TRACE-ID, ("validate-by-node", fn:node-name($node))),
  let $schema := helper:get-schema-for-node($node)
  let $schema-report := xsd-validator:validate-node(map:get($schema, "namespace"), map:get($schema, "uri"), $node)
  let $schematrons := helper:get-schematrons-for-node($node, map:get($schema, "uri"))
  let $schematron-reports := $schematrons ! sch-validator:validate-node($node, .,())
  let $result := json:object()
  =>map:with("schema", map:get($schema-report, "schema"))
  return (
    if (fn:exists($schematron-reports))
    then map:put($result,"schematron", $schematron-reports ! map:get(., "schematron"))
    else (),
    $result
  )
};