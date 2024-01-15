xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/validation/schema/schema-validator";

import module namespace helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";
declare option xdmp:mapping "false";

declare variable $eval-options as map:map := map:map()
=>map:with("isolation", "same-statement")
=>map:with("update", "false");

declare function local:validate-xml(
  $namespace as xs:string,
  $schema-uri as xs:string,
  $uri as xs:string
) as item()*
{
  let $query := fn:concat(
    'xquery version "1.0-ml"; ',
    'import schema "', $namespace, '" at "', $schema-uri, '"; ',
    'declare variable $uri as xs:string external; ',
    'xdmp:validate(fn:doc($uri), "strict")'
  )
  return (
    $query,
    xdmp:eval($query, (xs:QName("uri"), $uri), $eval-options)
  )
};
