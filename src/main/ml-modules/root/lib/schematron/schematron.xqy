xquery version "1.0-ml";
(: Copyright (c) 2020 MarkLogic Corporation :)
module namespace schematron = "http://marklogic.com/xdmp/my-schematron";
import module namespace ml-schematron="http://marklogic.com/xdmp/schematron" at "/MarkLogic/schematron/schematron.xqy";

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";

declare option xdmp:mapping "false";

declare variable $TRACE_ID as xs:string := "koop-schematron";

declare variable $SVRL-FOR-XSLT2 := "iso-schematron/iso_svrl_for_xslt2_wrapper.xsl";
declare variable $INCLUDE := "/MarkLogic/schematron/iso-schematron/iso_dsdl_include.xsl";
declare variable $EXPAND := "/MarkLogic/schematron/iso-schematron/iso_abstract_expand.xsl";

(:~
 : Empty params wrapper for the schematron:compile function
 :
 : @param $schema     the schematron schema node to compile
 : @return The compiled schematron schema as validator-xslt
 :)
declare function schematron:compile(
    $schema as element(sch:schema)
) as document-node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside compile#1")),
  schematron:compile($schema, ())
};

(:~
 : Compile Schematron schema and return the validator XSLT.
 : Default behaviour is no validation of the schematron schema
 : If schema validation is required, pass in a parameter key 'validate-schema' with value true
 : Throws an error if the schematron schema is bad
 :
 : @param $schema     the schematron schema node to compile
 : @param $params     map with parameters for the transformation
 : @return The compiled schematron schema as validator-xslt
 :)
declare function schematron:compile(
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

(:~
 : Empty params wrapper for the schematron:put function
 :
 : @param $schematron-uri     the uro of the schematron schema in teh schemas database
 : @return empty-sequence
 :)
declare function schematron:put(
  $schematron-uri as xs:string
) as empty-sequence()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside put#1")),
  schematron:put($schematron-uri, ())
};

(:~
 : Compile Schematron schema from Schemas database and store the compiled schema in modules database
 : Default behaviour is no validation of the schematron schema
 : If schema validation is required, pass in a parameter key 'validate-schema' with value true
 : Throws an error if the schematron schema is bad or cannot be found
 :
 : @param $schematron-uri     the uri of the schematron schema in teh schemas database
 : @param $params             map with parameters for the transformation
 : @return empty-sequence
 :)
declare function schematron:put(
  $schematron-uri as xs:string,
  $params as map:map?
) as empty-sequence()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside put#2")),
  let $schema := xdmp:eval(
    $ml-schematron:get-schema,
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
  return xdmp:eval($ml-schematron:put-validator,
    ( xs:QName("validator-uri"), $validator-uri,
      xs:QName("validator-xslt"), $validator-xslt
    ),
    <options xmlns="xdmp:eval">
      <database>{xdmp:modules-database()}</database>
    </options>)
};

(:~
 : Wrapper for the default MarkLogic schematron:get function
 : Throws an error if the schematron schema cannot be found
 :
 : @param $schematron-uri     the uri of the schematron schema in teh schemas database
 : @return    the compiled validator-xslt from the modules database
 :)
declare function schematron:get(
  $schematron-uri as xs:string
) as document-node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside get#1")),
  ml-schematron:get($schematron-uri)
};

(:~
 : Empty params wrapper for the schematron:validate function
 :
 : @param  $document        document node to validate
 : @param  $validator-xslt  validator-xslt node to use for validation
 : @return  output of the validation in SVRL format
 :)
declare function schematron:validate(
  $document as node(),
  $validator-xslt as document-node()
) as node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside validate#2")),
  schematron:validate($document, $validator-xslt, ())
};

(:~
 : Validator function that validates the given document against teh given validator-xslt with an
 :
 : @param  $document        document node to validate
 : @param  $validator-xslt  validator-xslt node to use for validation
 : @return  output of the validation in SVRL format
 :)
declare function schematron:validate(
  $document as node(),
  $validator-xslt as document-node(),
  $params as map:map?
) as node()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside validate#3")),
  let $parameters := map:map()=>map:with("parameters", if (fn:exists($params)) then $params else map:map())
  return
    if (xdmp:node-kind($document)="document")
    then xdmp:xslt-eval($validator-xslt, $document, $parameters)
    else xdmp:xslt-eval($validator-xslt, document { $document }, $parameters)
};

(:~
 : Wrapper for the default MarkLogic schematron:delete function
 : Throws an error if the schematron schema cannot be found
 :
 : @param $schematron-uri     the uri of the schematron schema in teh schemas database
 : @return    empty-sequence
 :)
declare function schematron:delete(
  $schematron-uri as xs:string
) as empty-sequence()
{
  xdmp:trace($TRACE_ID, fn:concat("Inside schematron:delete#3")),
  ml-schematron:delete($schematron-uri)
};