xquery version "1.0-ml";
module namespace helper = "http://marklogic.com/schema-validator/trigger/helper";

declare option xdmp:mapping "false";

declare variable $OPTION_SCHEMA as xs:string := "/opera/options/schema";
declare variable $OPTION_SCHEMATRON as xs:string := "/opera/options/schematron";
declare variable $OPTION_VALIDATIEPLAN as xs:string := "/opera/options/validatieplan";

declare variable $TYPE_SCHEMA as xs:string := "type/schema";
declare variable $TYPE_SCHEMATRON as xs:string := "type/schematron";
declare variable $TYPE_VALIDATIEPLAN as xs:string := "type/validatieplan";
declare variable $TYPE_CATALOG as xs:string := "type/catalog";
declare variable $TYPE_VERSIEOVERZICHT as xs:string := "type/versieoverzicht";

declare function helper:set-collections-and-permissions(
    $uri as xs:string,
    $metadata as map:map?,
    $collections as xs:string*,
    $permissions as element(sec:permission)*
) as empty-sequence()
{
		xdmp:document-put-metadata($uri, $metadata),
		xdmp:document-set-collections($uri, $collections),
		xdmp:document-set-permissions($uri, $permissions)
};

declare function helper:delete-document(
  $uri as xs:string,
  $type as xs:string
) as empty-sequence()
{
  let $schemas-database := xdmp:database-name(xdmp:schema-database())
  return xdmp:invoke-function(
    function () {
      xdmp:log(fn:concat('*****Document ', $uri, " will be deleted from ", $schemas-database, ".*****")),
      if (fn:doc-available($uri))
      then xdmp:document-delete($uri)
      else xdmp:log("***Document " || $uri || " not found in " || $schemas-database || ".*****")
    },
    map:map()
    =>map:with("database", xdmp:schema-database())
    =>map:with("update", "true")
  ),
  if ($type eq "schematron")
  then xdmp:invoke-function(
    function() {
      let $module-to-delete := fn:concat($uri,"-validator.xsl")
      return (
        xdmp:log(fn:concat('*****Document ', $module-to-delete, " will be deleted from " || xdmp:database-name(xdmp:modules-database()) ||".*****")),
        if (fn:doc-available($module-to-delete))
        then xdmp:document-delete($module-to-delete)
        else xdmp:log("***Document " || $module-to-delete || " not found in " || xdmp:database-name(xdmp:modules-database()))
      )
    },
    map:map()
    =>map:with("database", xdmp:modules-database())
    =>map:with("update", "true")
  )
  else ()
};
