xquery version "1.0-ml";
import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";

declare option xdmp:mapping "false";
declare variable $TRACE-ID as xs:string := "sv-corb";

(: Sample query that returns all URIs :)
xdmp:trace($TRACE-ID, "Inside schematron uris module"),
let $uris := cts:uris("", (), cts:collection-query($const:TYPE_SCHEMATRON))
let $count := count($uris)
return (
	xdmp:trace($TRACE-ID, fn:concat("Found ", $count, " schematron uris")),
	$count, 
	$uris
)