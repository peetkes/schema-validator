xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "/triggers/helper.xqy";

(: load test data :)
xdmp:trace("sv-test","Helper test"),
test:load-test-file("test.xsd", xdmp:database(), "/test.xsd", (), ("triggers/helper-test")),
test:load-test-file("test.sch", xdmp:database(), "/test.sch", (), ("triggers/helper-test"));

(: test function helper:set-collections-and-permissions :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";

let $uri := "/test.xsd"
return (
  test:assert-true(fn:empty(xdmp:document-get-metadata($uri)), "metadata found for uri " || $uri),
  test:assert-true(fn:empty(xdmp:document-get-permissions($uri)), "permissions found for uri " || $uri),
  test:assert-false("type/schema" = xdmp:document-get-collections($uri), "collection type/schema found for uri " || $uri)
);

import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "/triggers/helper.xqy";

let $uri := "/test.xsd"
let $metadata := map:map()
=>map:with("key", "value")
let $collections := fn:distinct-values((xdmp:document-get-collections($uri),"type/schema"))
let $permissions := (xdmp:permission("schema-test-writer", "update"))
return helper:set-collections-and-permissions("/test.xsd", $metadata, $collections, $permissions);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
let $uri := "/test.xsd"
return (
  test:assert-true(fn:exists(xdmp:document-get-metadata($uri)), "metadata not set for uri " || $uri),
  test:assert-true(fn:exists(xdmp:document-get-permissions($uri)), "permissions not set for uri" || $uri),
  test:assert-true("type/schema" = xdmp:document-get-collections($uri), "collection type/schema found for uri " || $uri)
);

(: test function helper:delete-document :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace schematron = "http://marklogic.com/schema-validator/lib/validation/schematron/schematron-validator"
  at "/lib/validation/schematron/schematron-validator.xqy";

let $sch-options := map:map()=>map:with("database", xdmp:schema-database())
let $mod-options := map:map()=>map:with("database", xdmp:modules-database())

let $schema := map:map()
=>map:with("/test.xsd", fn:doc("/test.xsd"))
let $schematron := map:map()
=>map:with("/test.sch", fn:doc("/test.sch"))
let $_ := (
  xdmp:invoke-function(
    function() {
      map:keys($schema) ! xdmp:document-insert(., map:get($schema, .)),
      map:keys($schematron) ! xdmp:document-insert(., map:get($schematron, .))
    }, $sch-options),
  xdmp:invoke-function(
    function() { map:keys($schematron) ! schematron:put(.) }
  )
)

let $schemas := xdmp:invoke-function(
  function() {
    map:keys($schema) ! fn:doc(.),
    map:keys($schematron) ! fn:doc(.)
  }, $sch-options)
let $schematrons := xdmp:invoke-function(
  function() {
    map:keys($schematron) ! fn:doc(fn:concat(., "-validator.xsl"))
  }, $mod-options)
return (
  test:assert-true(fn:exists($schemas), "schema not in schemas database"),
  test:assert-true(fn:exists($schematrons), "schematron not in schemas database")
);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "/triggers/helper.xqy";

let $schema := "/test.xsd"
let $schematron := "/test.sch"
return (
  helper:delete-document("/test.sch", "schematron"),
  helper:delete-document("/test.xsd", "schema")
);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";

let $sch-options := map:map()=>map:with("database", xdmp:schema-database())
let $mod-options := map:map()=>map:with("database", xdmp:modules-database())

let $schema-uri := "/test.xsd"
let $schematron-uri := "/test.sch"
let $schema-exists := xdmp:invoke-function(
  function() {
    fn:doc-available($schema-uri)
  }, $sch-options)
let $schematron-exists := xdmp:invoke-function(
  function() {
    fn:doc-available($schematron-uri)
  }, $sch-options)
let $schematron-mod-exists := xdmp:invoke-function(
  function() {
    fn:doc-available(fn:concat($schematron-uri, "-validator.xsl"))
  }, $mod-options)

return (
  test:assert-false($schema-exists, "schema exists in schema database"),
  test:assert-false($schematron-exists, "schematron exists in schema database"),
  test:assert-false($schematron-mod-exists, "schematron exists in modules database")
);