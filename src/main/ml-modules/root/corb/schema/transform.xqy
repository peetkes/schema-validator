xquery version "1.0-ml";
import module namespace util = "http://koop.overheid.nl/lvbb/corb/util" at "/corb/util.xqy";

(:
declare namespace cat = "urn:oasis:names:tc:entity:xmlns:xml:catalog";
:)

declare option xdmp:mapping "false";

declare variable $URI external;

(:declare private function local:adjust-node(
  $node as node()
) as empty-sequence()
{
  let $location := $node/@schemaLocation/fn:string()
  let $catalog-uri := cts:uris((), ("limit=1"), cts:element-attribute-range-query(xs:QName("cat:uri"), xs:QName("name"), "=", $location))
  let $prefix := fn:string-join(fn:tokenize($catalog-uri,"/")[1 to last()-1] ,"/")
  let $newLocation := fn:doc($catalog-uri)//cat:uri[@name eq $location]/@uri/fn:string()
  return xdmp:node-replace($node/@schemaLocation, attribute schemaLocation { fn:concat($prefix, "/",$newLocation) })
};

declare private function local:adjust-absolute-imports-includes(
    $uri as xs:string
) as empty-sequence()
{
  let $imports := fn:doc($uri)/descendant-or-self::xs:import[fn:matches(@schemaLocation/fn:string(), "^https?://")]
  for $import in $imports
  return local:adjust-node($import),
  let $includes := fn:doc($uri)/descendant-or-self::xs:include[fn:matches(@schemaLocation/fn:string(), "^https?://")]
  for $include in $includes
  return local:adjust-node($include)
};

declare private function local:adjust-relative-imports-includes(
  $uri as xs:string
) as empty-sequence()
{
  ()
};

declare private function local:get-query(
    $group as xs:string,
    $type as xs:string
) as cts:query
{
  cts:and-query((
    cts:field-range-query("schemaGroup","=", $group),
    cts:collection-query(fn:concat("/type/", $type))
  ))
};
:)
xdmp:trace("koop-corb", "Calling Corb schema transform on URI: " || $URI),
xdmp:invoke-function(function() { util:adjust-schemaLocation($URI) }),
let $collections := xdmp:document-get-collections($URI)
let $permissions := xdmp:document-get-permissions($URI)
let $schema-to-copy := xdmp:invoke-function(function() { fn:doc($URI) })
return xdmp:invoke-function(
    function() {
      xdmp:trace("koop-corb", "Should copy to schemas database"),
      xdmp:document-insert($URI, $schema-to-copy, $permissions, $collections )
    },
    map:map()
    =>map:with("database", xdmp:database("lvbb-stop-schemas"))
)

(:
)let $schema := fn:doc($URI)/element()
let $has-absolute-path := fn:fold-left(function($a, $z) { $a or $z }, fn:false(), $schema//xs:import/@schemaLocation/fn:string())
return (
  if ($has-absolute-path)
  then xdmp:invoke-function(function() { local:adjust-absolute-imports-includes($URI) })
  else xdmp:invoke-function(function() { local:adjust-relative-imports-includes($URI) }),
  let $collections := xdmp:document-get-collections($URI)
  let $permissions := xdmp:document-get-permissions($URI)
  let $schema-to-copy := xdmp:invoke-function(function() { fn:doc($URI) })
  return xdmp:invoke-function(
    function() {
      xdmp:trace("koop-corb", "Should copy to schemas database"),
      xdmp:document-insert($URI, $schema-to-copy, $permissions, $collections )
    },
    map:map()
    =>map:with("database", xdmp:database("lvbb-stop-schemas"))
  )
)
:)