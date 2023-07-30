xquery version "1.0-ml";
import module namespace util = "http://koop.overheid.nl/lvbb/corb/util" at "/corb/util.xqy";
import module namespace schematron = "http://marklogic.com/xdmp/my-schematron" at "/lib/schematron/schematron.xqy";

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

xdmp:trace("koop-corb", "Calling Corb schematron transform on URI: " || $URI),
xdmp:invoke-function(function() { util:adjust-schemaLocation($URI) }),
let $collections := xdmp:document-get-collections($URI)
let $permissions := xdmp:document-get-permissions($URI)
let $schematron-to-compile := xdmp:invoke-function(function() { fn:doc($URI) })
return (
    xdmp:invoke-function(
        function() {
          xdmp:trace("koop-corb", "Should copy to schemas database"),
          xdmp:document-insert($URI, $schematron-to-compile, $permissions, $collections )
        },
        map:map()
        =>map:with("database", xdmp:database("lvbb-stop-schemas"))
    ),
    xdmp:invoke-function(
        function() {
          xdmp:trace("koop-corb", "Should compile schematron and store in modules database"),
          schematron:put($URI, $PARAMS)
        }
    )
)