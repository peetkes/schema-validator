xquery version "1.0-ml";
import module namespace util = "http://koop.overheid.nl/lvbb/corb/util" at "/corb/util.xqy";

declare option xdmp:mapping "false";

declare variable $URI external;

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
