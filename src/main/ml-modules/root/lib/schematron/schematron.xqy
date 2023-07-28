xquery version "1.0-ml";
module namespace local = "http://marklogic.com/xdmp/my-schematron";
import module namespace schematron="http://marklogic.com/xdmp/schematron" at "/MarkLogic/schematron/schematron.xqy";

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";

declare option xdmp:mapping "false";

declare variable $TRACE_ID as xs:string := "koop-schematron";

declare variable $SVRL-FOR-XSLT2 := "iso-schematron/iso_svrl_for_xslt2_wrapper.xsl";
declare variable $INCLUDE := "/MarkLogic/schematron/iso-schematron/iso_dsdl_include.xsl";
declare variable $EXPAND := "/MarkLogic/schematron/iso-schematron/iso_abstract_expand.xsl";

(: Compile Schematron schema and return the validator XSLT :)
declare function local:compile(
    $schema as element(sch:schema)
) as document-node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside compile#1")),
  local:compile($schema, ())
};

(: Compile Schematron schema and return the validator XSLT :)
declare function local:compile(
    $schema as element(sch:schema),
    $params as map:map?
) as document-node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside compile#2")),
  let $step1 := xdmp:xslt-invoke($INCLUDE, document { $schema }, $params)

  let $validate-schema :=
    if (xs:string(map:get($params, "validate-schema"))="true")
    then validate full { $step1 }
    else ()

  let $step2 := xdmp:xslt-invoke($EXPAND, $step1, $params)
  let $validator-xslt := xdmp:xslt-invoke($SVRL-FOR-XSLT2, $step2, $params)
  return document { $validator-xslt }
};

(: Compile Schematron schema from Schemas database and store the compiled schema in modules database :)
declare function local:put(
  $schematron-uri as xs:string
) as empty-sequence()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside put#1")),
  local:put($schematron-uri, ())
};

(: Compile Schematron schema from schema database and store the compiled schema in modules database :)
declare function local:put(
  $schematron-uri as xs:string,
  $params as map:map?
) as empty-sequence()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside put#2")),
  let $schema := xdmp:eval(
    $schematron:get-schema,
    (xs:QName("schematron-uri"), $schematron-uri),
    <options xmlns="xdmp:eval">
      <database>{xdmp:schema-database()}</database>
    </options>)

  let $schema-presence-check :=
    if (fn:exists ($schema))
    then ()
    else (fn:error((), 'SCHEMATRON-SCHEMANOTFOUND', $schematron-uri))

  let $step1 := xdmp:xslt-invoke($INCLUDE, $schema, $params)
  let $validate-schema :=
    if (xs:string(map:get($params, "validate-schema"))="true")
    then validate full { $step1 }
    else ()

  let $step2 := xdmp:xslt-invoke($EXPAND, $step1, $params)
  let $validator-xslt := xdmp:xslt-invoke($SVRL-FOR-XSLT2, $step2, $params)
  let $validator-uri := fn:concat($schematron-uri,"-validator.xsl")
  return xdmp:eval($schematron:put-validator,
    ( xs:QName("validator-uri"), $validator-uri,
      xs:QName("validator-xslt"), $validator-xslt
    ),
    <options xmlns="xdmp:eval">
      <database>{xdmp:modules-database()}</database>
    </options>)
};

declare function local:get(
  $schematron-uri as xs:string
) as document-node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside get#1")),
  schematron:get($schematron-uri)
};

(: Validate a document using schematron :)
declare function local:validate(
  $document as node(),
  $validator-xslt as document-node()
) as node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside validate#2")),
  local:validate($document, $validator-xslt,map:map())
};

declare function local:validate(
  $document as node(),
  $validator-xslt as document-node(),
  $params as map:map
) as node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside validate#3")),
  let $parameters := map:map()=>map:with("parameters", $params)
  return
    if (xdmp:node-kind($document)="document")
    then xdmp:xslt-eval($validator-xslt, $document, $parameters)
    else xdmp:xslt-eval($validator-xslt, document { $document }, $parameters)
};

