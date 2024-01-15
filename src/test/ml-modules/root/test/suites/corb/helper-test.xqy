xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";

declare option xdmp:mapping "false";
declare variable $permissions as element()+ := (xdmp:permission("schema-test-writer", "update"));

xdmp:trace("sv-test","Helper test"),
test:load-test-file("test.xsd", xdmp:database(), "/test.xsd", $permissions, ("corb/helper-test","type/schema")),
test:load-test-file("test.sch", xdmp:database(), "/test.sch", $permissions, ("corb/helper-test","type/schematron")),
test:load-test-file("include.sch", xdmp:database(), "/include.sch", $permissions, ("corb/helper-test", "type/schematron"));

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/corb/helper" at "/corb/helper.xqy";

declare namespace sch="http://purl.oclc.org/dsdl/schematron";

let $xsd-imports := fn:doc("/test.xsd")//xs:import
let $_ := xdmp:invoke-function( function() { helper:adjust-schema-location("/test.xsd") })
let $xsd-modifiedImports := xdmp:invoke-function( function() { fn:doc("/test.xsd")//xs:import })
return (
  xdmp:trace("sv-test", ("xsd-imports", $xsd-imports, "xsd-modifiedImports", $xsd-modifiedImports)),
  for $import in $xsd-imports
  let $schemaLocation := $import/@schemaLocation/fn:string()
  let $modifiedSchemaLocation := $xsd-modifiedImports[@namespace eq $import/@namespace]/@schemaLocation/fn:string()
  return (
    xdmp:trace("sv-test",("schemaLocation", $schemaLocation, "modifiedSchemaLocation", $modifiedSchemaLocation)),
    test:assert-not-equal($schemaLocation, $modifiedSchemaLocation, "Not equal " || $schemaLocation)
  )
);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/corb/helper" at "/corb/helper.xqy";

declare namespace sch="http://purl.oclc.org/dsdl/schematron";

let $sch-includes := fn:doc("/test.sch")//sch:include
let $_ := xdmp:invoke-function( function() { helper:adjust-schematron-location("/test.sch") })
let $sch-modifiedIncludes := xdmp:invoke-function( function() { fn:doc("/test.sch")//sch:include })
return (
  xdmp:trace("sv-test", ("sch-includes", $sch-includes, "sch-modifiedIncludes", $sch-modifiedIncludes)),
  let $modified := $sch-modifiedIncludes/@href/fn:string()
  for $include in $sch-includes
  let $href := $include/@href/fn:string()
  return (
    xdmp:trace("sv-test",("href", $href, "modified", $modified)),
    test:assert-true(fn:not($href = $modified), "Not equal " || $href)
  )
);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/corb/helper" at "/corb/helper.xqy";

let $uri := "/some/location/opengis/gml/3.2.1/basicTypes.xsd"
let $version := "1.3.0"
let $expected := "http://schemas.opengis.net/gml/3.2.1/basicTypes.xsd"
let $actual := helper:get-catalog-name-for-uri($uri, $version)

return test:assert-equal($expected, $actual, $actual || " not equal " || $expected)