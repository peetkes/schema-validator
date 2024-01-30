xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/aanlevering/query-utilities";

import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";

declare option xdmp:mapping "false";

declare function local:get-publicatie-from-opdracht(
  $opdracht-uri as xs:string
) as node()?
{
  if (fn:doc-available($opdracht-uri)
  then ()
  else ()
};