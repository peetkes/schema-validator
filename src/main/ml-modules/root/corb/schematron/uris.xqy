xquery version "1.0-ml";

declare option xdmp:mapping "false";
declare variable $TRACE-ID as xs:string := "sv-corb";

(: Sample query that returns all URIs :)
xdmp:trace($TRACE-ID, "Inside schematron uris module"),
let $uris := cts:uris("", (), cts:collection-query("type/schematron"))
let $count := count($uris)
return (
	xdmp:trace($TRACE-ID, fn:concat("Found ", $count, " schematron uris")),
	$count, 
	$uris
)