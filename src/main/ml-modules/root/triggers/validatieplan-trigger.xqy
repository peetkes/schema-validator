xquery version "1.0-ml";
import module namespace trgr="http://marklogic.com/xdmp/triggers" at "/MarkLogic/triggers.xqy";
import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "helper.xqy";

declare namespace catalog = "urn:oasis:names:tc:entity:xmlns:xml:catalog";

declare option xdmp:mapping "false";

declare variable $trgr:uri as xs:string external;
declare variable $trgr:trigger as node() external;

declare variable $update-kind as xs:string := $trgr:trigger//trgr:update-kind/fn:data();
declare variable $plan-pattern as xs:string := ".*/validatieplannen/.*\.xml";

let $message := 
	switch ($update-kind)
	case "modify" return "modified"
	case "delete" return "deleted"
	default return "created"
let $permissions := (xdmp:permission("schema-test-writer", "update"))
let $collections := (
  $helper:OPTION_VALIDATIEPLAN,
  if (fn:matches($trgr:uri, $plan-pattern)) then $helper:TYPE_VALIDATIEPLAN else ()
)

return (
	xdmp:log(fn:concat('*****Document ', $trgr:uri, ' was ', $message, '.*****')),
	if ($update-kind = ("modify", "create"))
	then helper:set-collections-and-permissions($trgr:uri,(), $collections, $permissions)
	else helper:delete-document($trgr:uri, $helper:TYPE_VALIDATIEPLAN)
)
