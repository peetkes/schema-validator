xquery version "1.0-ml";
import module namespace helper = "http://marklogic.com/schema-validator/corb/helper" at "/corb/helper.xqy";
import module namespace schematron = "http://marklogic.com/schema-validator/lib/validation/schematron/schematron-validator"
  at "/lib/validation/schematron/schematron-validator.xqy";

declare namespace sch="http://purl.oclc.org/dsdl/schematron";

declare option xdmp:mapping "false";

declare variable $URI external;
declare variable $PARAMS := map:map()
=>map:with('phase', '#ALL')
=>map:with('terminate', fn:false())
=>map:with('generate-fired-rule', fn:true())
=>map:with('generate-paths', fn:true())
=>map:with('diagnose', fn:false())
=>map:with('allow-foreign', fn:true())
=>map:with('validate-schema', fn:false());

xdmp:trace($helper:TRACE-ID, "TRANSFORM-SCHEMATRON::Calling Corb schematron transform on URI: " || $URI),
xdmp:invoke-function(function() { helper:adjust-schematron-location($URI) }),
let $schematron-version := fn:doc($URI)/node()/sch:p[fn:starts-with(.,"Versie")]/fn:data()
let $version := if (fn:exists($schematron-version))
  then fn:tokenize($schematron-version, " ")[last()]
  else ()
let $schematron-collection :=
  if (fn:exists($version))
  then fn:concat("version/", $version)
  else ()
let $name := helper:get-catalog-name-for-uri($URI, $version)
let $collections := fn:distinct-values((xdmp:document-get-collections($URI), $schematron-collection))
let $permissions := xdmp:document-get-permissions($URI)
let $schematron-to-compile := xdmp:invoke-function(function() { fn:doc($URI) })
return (
  xdmp:trace($helper:TRACE-ID,("TRANSFORM-SCHEMATRON::name", $name, "uri", $URI, "version", $version)),
  xdmp:invoke-function(
    function() {
      xdmp:trace($helper:TRACE-ID, "Should copy to schemas database"),
      xdmp:document-insert($URI, $schematron-to-compile, $permissions, $collections )
    },
    map:map()
    =>map:with("database", xdmp:schema-database())
    =>map:with("update","true")
  ),
  xdmp:invoke-function(
    function() {
      xdmp:trace($helper:TRACE-ID, "Should compile schematron and store in modules database"),
      schematron:put($URI, $PARAMS),
      if (fn:exists($name))
      then (
        let $metadata := xdmp:document-get-metadata($URI)
        return (
          map:put($metadata, "catalog-name", $name),
          xdmp:document-set-metadata($URI, $metadata)
        )
      )
      else ()
    },
    map:map()
    =>map:with("update","true")
  )
)