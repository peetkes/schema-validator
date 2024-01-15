xquery version "1.0-ml";
import module namespace trgr="http://marklogic.com/xdmp/triggers" at "/MarkLogic/triggers.xqy";
import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "helper.xqy";
import module namespace validation-helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";

declare namespace catalog = "urn:oasis:names:tc:entity:xmlns:xml:catalog";

declare option xdmp:mapping "false";

declare variable $trgr:uri as xs:string external;
declare variable $trgr:trigger as node() external;

declare variable $update-kind as xs:string := $trgr:trigger//trgr:update-kind/fn:data();
declare	variable $uri-pattern as xs:string := ".*/schema/([^/]+)/.*";
declare variable $schema-pattern as xs:string := ".*/schema/(([^/]+)/)+.*\.xsd";
declare variable $catalog-pattern as xs:string := ".*/schema/(([^/]+)/)+.*catalog\.xml";
declare variable $versieoverzicht-pattern as xs:string := ".*/schema/(([^/]+)/)+.*versie\.xml";

let $message :=
	switch ($update-kind)
	case "modify" return "modified"
	case "delete" return "deleted"
	default return "created"

let $group := fn:replace($trgr:uri, $uri-pattern, "$1")
let $targetNamespace := fn:doc($trgr:uri)/node()/@targetNamespace/fn:data()
let $version := fn:doc($trgr:uri)/node()/(@version|@schemaversie)/fn:data()
let $version-components := validation-helper:get-version-components($version)
let $metadata := map:map()
  =>map:with("schemaGroup", $group)
  =>map:with("namespace", $targetNamespace)

let $permissions := (xdmp:permission("schema-test-writer", "update"))
let $collections := (
  $helper:OPTION_SCHEMA,
  fn:concat("group/", $group),
  if (fn:matches($trgr:uri, $schema-pattern)) then $helper:TYPE_SCHEMA else (),
  if (fn:matches($trgr:uri, $catalog-pattern)) then $helper:TYPE_CATALOG else (),
  if (fn:matches($trgr:uri, $versieoverzicht-pattern)) then $helper:TYPE_VERSIEOVERZICHT else (),
  if (fn:exists($version)) then fn:concat("version/", $version) else ()
)

return (
	xdmp:log(fn:concat('*****Document ', $trgr:uri, ' was ', $message, '.*****')),
	if ($update-kind = ("modify", "create"))
	then helper:set-collections-and-permissions($trgr:uri, $metadata + $version-components, $collections, $permissions)
	else helper:delete-document($trgr:uri, $helper:TYPE_SCHEMA)
)
