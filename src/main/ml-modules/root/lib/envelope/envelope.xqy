xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/envelope/envelope";

import module namespace constants = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "sv-envelope";

declare function local:create(
  $node as node(),
  $params as map:map
) as document-node()
{
  xdmp:trace($TRACE-ID, ("params", $params)),
  let $version := $node/@schemaversie/fn:data()
  let $root-node := fn:local-name($node)
  let $stylesheet :=
    if (fn:exists($version))
    then fn:concat("/lib/stylesheets/", $version, "/create-envelope.xsl")
    else "/lib/stylesheets/create-envelope.xsl"

  return (
    xdmp:trace($TRACE-ID, ("version", $version, "root", $root-node, "stylesheet", $stylesheet)),
    xdmp:xslt-invoke($stylesheet, $node, $params=>map:with("root", $root-node))
  )
};