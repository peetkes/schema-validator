xquery version "1.0-ml";

declare option xdmp:mapping "false";

(: Sample query that returns all URIs :)
xdmp:trace("koop-corb", "Inside schematron uris module"),
let $uris := cts:uris("", (), cts:collection-query("/type/schematron"))
let $count := count($uris)
return (
	xdmp:trace("koop-corb", fn:concat("Found ", $count, " schematron uris")),
	$count, 
	$uris
)