xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/test/lib/helper";

import module namespace trgr="http://marklogic.com/xdmp/triggers" at "/MarkLogic/triggers.xqy";

declare option xdmp:mapping "false";

declare variable $triggers as xs:string+ := (
  "SchemaCreateTrigger",
  "SchemaDeleteTrigger",
  "SchemaModifyTrigger",
  "SchematronCreateTrigger",
  "SchematronDeleteTrigger",
  "SchematronModifyTrigger",
  "ValidatieplanCreateTrigger",
  "ValidatieplanDeleteTrigger",
  "ValidatieplanModifyTrigger"
);

declare variable $config-collections as xs:string+ := (
  "type/schema",
  "type/schematron",
  "type/catalog",
  "type/versieoverzicht"
);

declare function local:enable-triggers() as empty-sequence()
{
  local:toggle-triggers(fn:true())
};

declare function local:disable-triggers() as empty-sequence()
{
  local:toggle-triggers(fn:false())
};

declare private function local:toggle-triggers(
  $enable as xs:boolean
) as empty-sequence()
{
  xdmp:invoke-function(
    function() {
      try {
        $triggers ! (if ($enable) then trgr:trigger-enable(.) else trgr:trigger-disable(.))
      } catch ($ex) {
      xdmp:trace("sv-test", $ex/error:format-string)
      }
    },
    map:map()
    =>map:with("database", xdmp:triggers-database())
  )
};

declare function local:copy-configuration() as empty-sequence()
{
  let $config-count := xdmp:invoke-function(
    function() {
      fn:count(fn:collection($config-collections))
    },
    map:map()
    =>map:with("database", xdmp:database("%%mlAppName%%-content"))
  )
  return (
    xdmp:trace("sv-test", ("count", $config-count)),
    if ($config-count eq fn:count(fn:collection($config-collections)))
    then xdmp:trace("sv-test", "nothing to copy")
    else (
        xdmp:trace("sv-test", ("copy " || $config-count || " schemas to test db")),
        xdmp:invoke-function(function() { $config-collections ! xdmp:collection-delete(.) }),
        let $config-files := xdmp:invoke-function(
          function() {
            let $uris := cts:uris((),(), cts:collection-query($config-collections))
            for $uri in $uris
            return map:map()
            =>map:with("uri", $uri)
            =>map:with("content", fn:doc($uri))
            =>map:with("permissions", xdmp:document-get-permissions($uri,"objects"))
            =>map:with("collections", xdmp:document-get-collections($uri))
            =>map:with("metadata", xdmp:document-get-metadata($uri))
          },
          map:map()
          =>map:with("database", xdmp:database("%%mlAppName%%-content"))
        )
        for $config-file in $config-files
        return xdmp:invoke-function(
          function() {
            xdmp:document-insert(map:get($config-file,"uri"), map:get($config-file, "content"),
              map:map()
              =>map:with("permissions", map:get($config-file,"permissions"))
              =>map:with("collections", map:get($config-file,"collections"))
              =>map:with("metadata", map:get($config-file,"metadata"))
            )
          }
        )
    )
  )
};
