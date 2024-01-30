xquery version "1.0-ml";
import module namespace trgr="http://marklogic.com/xdmp/triggers" at "/MarkLogic/triggers.xqy";
import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";
import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "helper.xqy";
import module namespace validation-helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";

declare namespace catalog = "urn:oasis:names:tc:entity:xmlns:xml:catalog";

declare option xdmp:mapping "false";

declare variable $trgr:uri as xs:string external;
declare variable $trgr:trigger as node() external;

declare variable $update-kind as xs:string := $trgr:trigger//trgr:update-kind/fn:data();
declare	variable $uri-pattern as xs:string := ".*/schema/([^/]+)/.*";
declare variable $schematron-pattern as xs:string := ".*/schema/(([^/]+)/)+.*\.sch";

let $message :=
	switch ($update-kind)
	case "modify" return "modified"
	case "delete" return "deleted"
	default return "created"

let $group := fn:replace($trgr:uri, $uri-pattern, "$1")
let $version := fn:doc($trgr:uri)/node()/*:p[fn:starts-with(.,"Versie")]/fn:data()
let $version-components := if (fn:exists($version))
then validation-helper:get-version-components(fn:tokenize($version, " ")[last()])
else ()
let $metadata := map:map()
=>map:with("schemaGroup", $group)
let $permissions := xdmp:default-permissions()(:)(xdmp:permission("schema-test-writer", "update"),xdmp:permission("schema-test-reader", "read")):)
let $collections := (
  $const:OPTION_SCHEMATRON,
  fn:concat("group/", $group),
  if (fn:matches($trgr:uri, $schematron-pattern)) then $const:TYPE_SCHEMATRON else (),
  if (map:contains($version-components, $const:VERSION_KEY))
  then fn:concat("version/", map:get($version-components, $const:VERSION_KEY))
  else ()
)

return (
	xdmp:log(fn:concat('*****Document ', $trgr:uri, ' was ', $message, " by user ", xdmp:get-current-user(), '.*****' )),
	if ($update-kind = ("modify", "create"))
	then helper:set-collections-and-permissions($trgr:uri, $metadata + $version-components, $collections, $permissions)
	else helper:delete-document($trgr:uri, $const:TYPE_SCHEMATRON)
)
