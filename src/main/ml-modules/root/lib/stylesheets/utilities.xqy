xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/stylesheets/utilities";

declare variable $ns as xs:string := "http:koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare function local:convert-json-string-to-xml(
  $string as xs:string
) as element()*
{
    if (fn:matches($string, "\{.*\}\s*,"))
    then
      let $messages := (fn:tokenize($string,"\}\s*,") ! fn:concat(.,"}"))[1 to last() - 1]
      for $message in $messages
      let $json := xdmp:from-json-string($message)
      return element { fn:QName($ns, "error") } {
        for $key in map:keys($json)
        return element { fn:QName($ns, $key) } { map:get($json, $key) }
      }
    else element { fn:QName($ns, "error") } { $string}
};
