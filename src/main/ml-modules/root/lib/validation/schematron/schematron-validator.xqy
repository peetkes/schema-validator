xquery version "1.0-ml";
(: Copyright (c) 2020 MarkLogic Corporation :)
module namespace schematron = "http://marklogic.com/schema-validator/lib/validation/schematron/schematron-validator";
import module namespace ml-schematron="http://marklogic.com/xdmp/schematron" at "/MarkLogic/schematron/schematron.xqy";

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace opera = "http:koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare variable $TRACE_ID as xs:string := "sv-schematron";

declare variable $SVRL-FOR-XSLT2 := "iso-schematron/iso_svrl_for_xslt2_wrapper.xsl";
declare variable $INCLUDE := "/MarkLogic/schematron/iso-schematron/iso_dsdl_include.xsl";
declare variable $EXPAND := "/MarkLogic/schematron/iso-schematron/iso_abstract_expand.xsl";

declare variable $SCHEMATRON_REPORT as xs:string := "schematron-report.xsl";

declare variable $eval-options as map:map := map:map()
=>map:with("isolation", "same-statement")
=>map:with("update", "false");

(:~
 : Function: validate-node
 :
 : @param $node           node to validate
 : @param $schematron-uri uri of the schematron file to use for validation
 : @param $params         optional list of parameters to use for the validation
 : @result json:object containing the result
 :)
declare function validate-node(
  $node as node(),
  $schematron-uri as xs:string,
  $params as map:map?
) as json:object
{
  let $report := schematron:validate($node, schematron:get($schematron-uri), $params)
  let $result := json:object()
    =>map:with("uri", $schematron-uri)
  return (
    if (fn:exists($report//*[fn:local-name() = ("successful-report","failed-assert")]))
    then (
      xdmp:trace($TRACE_ID,("report", $report)),
      map:put($result,"result", "fail"),
      map:put($result, "report", xdmp:xslt-invoke($SCHEMATRON_REPORT,$report))
    )
    else map:put($result,"result","success"),
    json:object()
      =>map:with("schematron", $result)
  )
};

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
  schematron:compile($schema,
    map:map()
    =>map:with("allow-foreign",fn:true())
  )
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
  let $step1 := xdmp:xslt-invoke($INCLUDE, document { $schema }, $params)

  let $params := if (fn:empty($params))
  then map:map()=>map:with("allow-foreign",fn:true())
  else $params=>map:with("allow-foreign",fn:true())

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
 : @param $schematron-uri     the uri of the schematron schema in the schemas database
 : @return empty-sequence
 :)
declare function schematron:put(
  $schematron-uri as xs:string
) as empty-sequence()
{
  schematron:put($schematron-uri,
    map:map()
    =>map:with("allow-foreign",fn:true())
  )
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
 : @param $schematron-uri     the uri of the schematron schema in the schemas database
 : @return    the compiled validator-xslt from the modules database
 :)
declare function schematron:get(
  $schematron-uri as xs:string
) as document-node()
{
  try {
    ml-schematron:get($schematron-uri)
  } catch ($ex) {
    xdmp:trace($TRACE_ID, ("recompile schematron", $schematron-uri)),
    schematron:put($schematron-uri, map:map()=>map:with("allow-foreign", fn:true())),
    ml-schematron:get($schematron-uri)
  }
};

(:~
 : Empty params wrapper for the schematron:validate function
 :
 : @param  $node            document node to validate
 : @param  $validator-xslt  validator-xslt node to use for validation
 : @return  output of the validation in SVRL format
 :)
declare function schematron:validate(
  $node as node(),
  $validator-xslt as document-node()
) as node()
{
  schematron:validate($node, $validator-xslt, ())
};

(:~
 : Validator function that validates the given document against teh given validator-xslt with an
 :
 : @param  $node            document node to validate
 : @param  $validator-xslt  validator-xslt node to use for validation
 : @return  output of the validation in SVRL format
 :)
declare function schematron:validate(
  $node as node(),
  $validator-xslt as document-node(),
  $params as map:map?
) as node()
{
  let $parameters := map:map()=>map:with("parameters", if (fn:exists($params)) then $params else map:map())
  return
    if (xdmp:node-kind($node)="document")
    then xdmp:xslt-eval($validator-xslt, $node, $parameters)
    else xdmp:xslt-eval($validator-xslt, document { $node }, $parameters)
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
  ml-schematron:delete($schematron-uri)
};