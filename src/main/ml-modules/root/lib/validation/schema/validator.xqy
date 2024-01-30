xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/validation/schema/validator";

declare namespace opera = "http:koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare variable $eval-options as map:map := map:map()
=>map:with("isolation", "same-statement")
=>map:with("update", "false");

declare variable $SCHEMA_REPORT as xs:string := "report.xsl";
declare variable $TRACE-ID as xs:string := "sv-validation";

(:~
 : Function:
 :
 : @param
 : @result
 :)
declare function local:validate-node(
  $namespace as xs:string,
  $schema-uri as xs:string,
  $node as node()
) as json:object
{
  let $query := fn:concat(
    'xquery version "1.0-ml"; ',
    'import schema "', $namespace, '" at "', $schema-uri, '"; ',
    'declare namespace opera = "http:koop.overheid.nl/lvbb/opera"; ',
    'declare variable $node as node() external; ',
    'xdmp:validate(document { $node }, "strict")'
  )
  let $report := xdmp:eval($query, (xs:QName("node"), $node), $eval-options)
  let $result := json:object()
    =>map:with("uri", $schema-uri)
  return (
    if (fn:empty($report/node()))
    then map:put($result,"result", "success")
    else (
      map:put($result,"result", "fail"),
      map:put($result, "report", xdmp:xslt-invoke($SCHEMA_REPORT, $report)/node())
    ),
    json:object()
    =>map:with("schema", $result)
  )
};
