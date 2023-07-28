xquery version "1.0-ml";
import module namespace trgr='http://marklogic.com/xdmp/triggers' at '/MarkLogic/triggers.xqy';

declare namespace catalog = "urn:oasis:names:tc:entity:xmlns:xml:catalog";

declare option xdmp:mapping "false";

declare variable $trgr:uri as xs:string external;
declare variable $trgr:trigger as node() external;

declare variable $update-kind as xs:string := $trgr:trigger//trgr:update-kind/fn:data();
declare	variable $uri-pattern as xs:string := "/schemas/([^/]+)/schema/([^/]+).*";
declare variable $catalog-pattern as xs:string := "/schemas/[^/]+/schema/.*catalog\.xml";
declare variable $versie-pattern as xs:string := "/schemas/[^/]+/schema/.*versie\.xml";
declare variable $schema-pattern as xs:string := "/schemas/[^/]+/schema/.*\.xsd";
declare variable $schematron-pattern as xs:string := "/schemas/[^/]+/schema/.*\.sch";

declare private function local:set-collections-and-permissions(
	$uri as xs:string
) as empty-sequence()
{
	let $release := fn:replace($uri, $uri-pattern, "$1")
	let $type := fn:replace($uri, $uri-pattern, "$2")
	let $is-catalog-file := fn:matches($uri, $catalog-pattern)
	let $is-versie-file := fn:matches($uri, $versie-pattern)
	let $is-schema-file := fn:matches($uri, $schema-pattern)
	let $is-schematron-file := fn:matches($uri, $schematron-pattern)
	let $metadata := map:new((
		map:entry("release", $release),
		map:entry("schemaGroup", $type)
	))
	let $collections := (
		fn:concat("/release/", $release), 
		fn:concat("/group/", $type),
		if ($is-catalog-file) then '/type/catalog' else (),
		if ($is-versie-file) then '/type/versie' else (),
		if ($is-schema-file) then '/type/schema' else (),
		if ($is-schematron-file) then '/type/schematron' else ()
	)
	let $permissions := (xdmp:permission("schema-test-writer", "update"))
	return (
		xdmp:document-put-metadata($uri, $metadata),
		xdmp:document-set-collections($uri, $collections),
		xdmp:document-set-permissions($uri, $permissions)
	)
};

let $message := 
	switch ($update-kind)
	case "modify" return "modified"
	case "delete" return "deleted"
	default return "created"

return (
	xdmp:log(fn:concat('*****Document ', $trgr:uri, ' was ', $message, '.*****')),
	if ($update-kind = ("modify", "create"))
	then local:set-collections-and-permissions($trgr:uri)
	else ()
)
