xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";

xdmp:trace("sv-test","Helper test"),

let $version := "1.3.4"
let $version-components := helper:get-version-components($version)
return (
  test:assert-equal(map:get($version-components, $helper:VERSION_MAJOR), "1",
    "Major version not equal to 1: " || map:get($version-components, $helper:VERSION_MAJOR)),
  test:assert-equal(map:get($version-components, $helper:VERSION_MINOR), "3",
    "Minor version not equal to 3: " || map:get($version-components, $helper:VERSION_MINOR)),
  test:assert-equal(map:get($version-components, $helper:VERSION_PATCH), "4",
    "Patch version not equal to 4: " || map:get($version-components, $helper:VERSION_PATCH)),
  test:assert-equal(map:get($version-components, $helper:VERSION_KEY), "1.3.4",
    "Version not equal to 1.3.4: " || map:get($version-components, $helper:VERSION_KEY))
),
let $version := "2001-12-12"
let $version-components := helper:get-version-components($version)
return (
  xdmp:trace("sv-test", ("version-componets", $version-components)),
  test:assert-false(map:contains($version-components, $helper:VERSION_MAJOR),
    "Major version found, should be empty: " || map:get($version-components, $helper:VERSION_MAJOR)),
  test:assert-false(map:contains($version-components, $helper:VERSION_MINOR),
    "Minor version found, should be empty: " || map:get($version-components, $helper:VERSION_MINOR)),
  test:assert-false(map:contains($version-components, $helper:VERSION_PATCH),
    "Patch version found, should be empty: " || map:get($version-components, $helper:VERSION_PATCH)),
  test:assert-equal(map:get($version-components, $helper:VERSION_KEY), $version,
    "Major version not equal to " || $version || ": " || map:get($version-components, $helper:VERSION_KEY))
);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";

let $version := "1.1.0"
let $namespace := "https://standaarden.overheid.nl/stop/imop/gio/"

let $actual := helper:find-version($version, $namespace)
let $expected := map:map()
=>map:with($helper:VERSION_MAJOR,"1")
=>map:with($helper:VERSION_MINOR,"3")
=>map:with($helper:VERSION_PATCH,"2")
=>map:with($helper:VERSION_KEY, "1.3.2")
=>map:with($helper:NAMESPACE_KEY, $namespace)

return (
  xdmp:trace("sv-test", ("actual", $actual, "expected", $expected)),
  test:assert-true(map:get($expected, $helper:VERSION_KEY) eq map:get($actual, $helper:VERSION_KEY),
    "Version actual equals version expected"
  ),
  for $key in map:keys($expected)
  return test:assert-equal(map:get($expected, $key), map:get($actual, $key),
    $key || " actual " || map:get($actual, $key) || " not equal to " || map:get($expected, $key))
);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";

declare variable $files  as map:map := json:object()
=>map:with("opdracht.xml", "http://www.overheid.nl/2017/lvbb")
=>map:with("manifest.xml", "http://www.overheid.nl/2017/lvbb")
=>map:with("gio-1.xml", ("https://standaarden.overheid.nl/lvbb/stop/aanlevering/",
  "https://standaarden.overheid.nl/stop/imop/data/"))
=>map:with("manifest-ow.xml", "http://www.geostandaarden.nl/bestanden-ow/manifest-ow")
=>map:with("owLocaties.xml", ("http://www.geostandaarden.nl/imow/bestanden/deelbestand",
  "http://www.geostandaarden.nl/bestanden-ow/standlevering-generiek",
  "http://www.geostandaarden.nl/imow/locatie"))
=>map:with("owRegelingsgebied.xml", ("http://www.geostandaarden.nl/imow/bestanden/deelbestand",
  "http://www.geostandaarden.nl/bestanden-ow/standlevering-generiek",
  "http://www.geostandaarden.nl/imow/regelingsgebied",
  "http://www.geostandaarden.nl/imow/locatie"))
=>map:with("owRegeltekst.xml", ("http://www.geostandaarden.nl/imow/bestanden/deelbestand",
  "http://www.geostandaarden.nl/bestanden-ow/standlevering-generiek",
  "http://www.geostandaarden.nl/imow/regels",
  "http://www.geostandaarden.nl/imow/locatie"))
=>map:with("publicatie.xml",  ("https://standaarden.overheid.nl/lvbb/stop/aanlevering/",
  "https://standaarden.overheid.nl/stop/imop/data/",
  "https://standaarden.overheid.nl/stop/imop/tekst/"));
xdmp:invoke-function(
  function() {
    for $file in map:keys($files)
    return (
      test:load-test-file($file, xdmp:database(), fn:concat("/test/", $file), (), ("validation/helper-test"))
    )
  }
),
xdmp:invoke-function(
  function() {
    for $file in map:keys($files)
    let $actual := helper:get-namespaces-in-scope(fn:doc(fn:concat("/test/", $file)))
    let $expected := map:get($files, $file)
    return (
      xdmp:trace("sv-test", ("actual", $actual)),
      test:assert-true(every $ns in $actual satisfies ($ns = $expected),
        fn:concat($file, ": actual not equal to expected: actual:",
        fn:string-join($actual, ","), " expected:",
         fn:string-join($expected, ",")))
    )
  }
);

