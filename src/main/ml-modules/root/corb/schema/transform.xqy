xquery version "1.0-ml";
import module namespace helper = "http://marklogic.com/schema-validator/corb/helper" at "/corb/helper.xqy";

declare option xdmp:mapping "false";

declare variable $URI external;

xdmp:trace($helper:TRACE-ID, "TRANSFORM-SCHEMA::Calling Corb schema transform on URI: " || $URI),
xdmp:invoke-function(function() { helper:adjust-schema-location($URI) }),
let $version := fn:doc($URI)/node()/@version/fn:data()
let $collection :=
  if (fn:exists($version))
  then fn:concat("version/", $version)
  else ()
let $name := helper:get-catalog-name-for-uri($URI, $version)
let $collections := fn:distinct-values((xdmp:document-get-collections($URI), $collection))
let $permissions := xdmp:document-get-permissions($URI)
let $schema-to-copy := xdmp:invoke-function(function() { fn:doc($URI) })
return (
  xdmp:trace($helper:TRACE-ID,("TRANSFORM-SCHEMA::name", $name, "version", $version)),
  if (fn:exists($name))
  then (
    let $metadata := xdmp:document-get-metadata($URI)
    return (
      map:put($metadata, "catalog-name", $name),
      xdmp:invoke-function(
        function() { xdmp:document-set-metadata($URI, $metadata) },
        map:map()=>map:with("update", "true")
      )
    )
  )
  else (),
  xdmp:invoke-function(
     function() {
       xdmp:trace($helper:TRACE-ID, "Should copy to schemas database"),
       xdmp:document-insert($URI, $schema-to-copy, $permissions, $collections)
     },
     map:map()
     =>map:with("database", xdmp:schema-database())
     =>map:with("update", "true")
  )
)
