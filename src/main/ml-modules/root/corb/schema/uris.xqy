xquery version "1.0-ml";
import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";

declare option xdmp:mapping "false";
declare variable $TRACE-ID as xs:string := "sv-corb";

(: Sample query that returns all URIs :)
xdmp:trace($TRACE-ID, "Inside schema uris module"),
let $uris := cts:uris("", (), cts:collection-query($const:TYPE_SCHEMA))
let $count := count($uris)
return (
	xdmp:trace($TRACE-ID, fn:concat("Found ", $count, " schema uris")),
	$count, 
	$uris
)