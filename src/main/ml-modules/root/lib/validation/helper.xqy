xquery version "1.0-ml";
(: Copyright (c) 2020 MarkLogic Corporation :)
module namespace local = "http://marklogic.com/schema-validator/lib/validation/helper";
import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";

declare namespace schemata = "https://standaarden.overheid.nl/stop/imop/schemata/";
declare namespace opera = "http:koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "sv-validation";
declare variable $version-pattern as xs:string := "^(\d+)\.(\d+)\.(\d+.*)$";

(:~
 : Function: get-version-components
 :
 : @param   $version the version to split in semantic version components major, minor and patch
 : major means not backwards compatible new functionality
 : minor means backwards compatible new functionality
 : patch means backwards compatible bugfixes

 : @result map containg full-version, major, minor and patch components
 :)
declare function local:get-version-components(
  $version as xs:string?
) as map:map?
{
  if (fn:matches($version, $version-pattern))
  then map:map()
  =>map:with($const:VERSION_KEY, $version)
  =>map:with($const:VERSION_MAJOR, fn:replace($version, $version-pattern, "$1"))
  =>map:with($const:VERSION_MINOR, fn:replace($version, $version-pattern, "$2"))
  =>map:with($const:VERSION_PATCH, fn:replace($version, $version-pattern, "$3"))
  else map:map()
  =>map:with($const:VERSION_KEY, $version)
};

(:~
 : Function: find-version
 : this function finds the schema for the version/namespace provided.
 : I that version is not available in the database it finds the maximum compatible version.
 : Basically means find the version that either has the same version or has the same major version and the maximum minor.patch version
 : that is available in the database.
 :
 : @param   $version    The version of the xml document
 : @param   $namespace  The namespace for the xml document
 : @result a map containing the version. namespace, major, minor and patch version numbers
 :)
declare function local:find-version(
  $version as xs:string,
  $namespace as xs:string
) as map:map?
{
  let $version-components := local:get-version-components($version)
  let $schema-query := cts:and-query((
    cts:collection-query($const:TYPE_SCHEMA),
    cts:field-range-query($const:NAMESPACE_KEY, "=", $namespace),
    cts:field-range-query($const:VERSION_KEY, "=", map:get($version-components, $const:VERSION_KEY))
  ))
  let $schema-uris := cts:uris((),(),$schema-query)
  return
    if (fn:exists($schema-uris))
    then xdmp:document-get-metadata($schema-uris)
    else local:find-max-compatible-version($version, $namespace)
};

(:~
 : Function: get-namespaces-in-scope
 : this function finds all distinct namespaces used in the given document
 :
 : @param  $node    node to get the distinct namespaces for
 : @result sequence of all distinct namespaces used in the node
 :)
declare function local:get-namespaces-in-scope(
  $node as node()
) as xs:string*
{
  fn:distinct-values(
    for $element in $node/descendant-or-self::*
    for $prefix in fn:in-scope-prefixes($element)[not(. = ('xml','opera', 'xlink'))]
    return fn:namespace-uri-for-prefix($prefix, $element)
  )
};

(:~
 : Function: get-schema-for-node
 : this function gets the proper schema version to use for xsd validation.
 : If the specific version is not found, it will get the highest available minor/patch version in the database
 :
 : @param $node   node to validate
 : @result map with namespace and uri of the schema to use for validation
 :)
declare function local:get-schema-for-node(
  $node as node()
) as map:map
{
  let $root := fn:local-name($node)
  let $version := $node/@schemaversie/fn:data()
  let $namespace := fn:namespace-uri($node)
  let $namespaces-in-scope := local:get-namespaces-in-scope($node)
  let $compatible-version := if (fn:exists($version)) then local:find-version($version, $namespace) else ()
  let $schema-query := cts:and-query((
    cts:collection-query("type/schema"),
    cts:field-range-query("namespace", "=", $namespace),
    if (fn:exists($compatible-version)) then cts:field-range-query("version", "=", map:get($compatible-version, "version")) else ()
  ))
  let $result := map:map()
    =>map:with("namespace", $namespace)
    =>map:with("uri", cts:uris((),("limit=1"),$schema-query))

  return (
    xdmp:trace($TRACE-ID,("version", $version, "compatible-version", $compatible-version, "namespaces-in-scope", $namespaces-in-scope, "result", $result)),
    $result
  )
};

(:~
 : Function: get-schematrons-for-node
 : this function will get a list of schematron uris to use, based on the metadata of the schema document and information pulled from the versieoverzicht of the specific document version
 :
 : @param $node     the node to validate
 : @param $schema-uri   the uir of the xsd schema used for schema validation
 : @result a sequence of schematron uri's
 :)
declare function local:get-schematrons-for-node(
  $node as node(),
  $schema-uri as xs:string
) as xs:string*
{
  xdmp:trace($TRACE-ID,("GET_SCHEMATRONS_FOR_NODE", "schema-uri", $schema-uri)),
  let $schema-md := xdmp:document-get-metadata($schema-uri)
  let $version := ($node/@schemaversie/fn:data(),map:get($schema-md, $const:VERSION_KEY))[1]
  let $catalog-name := map:get($schema-md, $const:CATALOG_NAME)
  let $modules :=
    if (fn:exists($version)) then local:get-modules($schema-uri, $version, $catalog-name)
    else ()
  let $schematrons := if (fn:exists($modules)) then local:get-schematrons($modules, $node) else ()
  return (
      xdmp:trace($TRACE-ID,("schema-md", $schema-md, "version", $version, "catalog-name", $catalog-name)),
      $schematrons
  )
};

(:~
 : Function: find-max-compatible-version
 : this function finds the maximum compatible version for a given version.
 : Basically means find the version that has the same major version and the maximum minor.patch version
 : that is available in teh database.
 :
 : @param   $version    The version of the xml document
 : @param   $namespace  The namespace for the xml document
 : @result a map containing the version. namespace, major, minor and patch version numbers
 :)
 declare private function local:find-max-compatible-version(
  $version as xs:string,
  $namespace as xs:string
) as map:map
{
  let $version-components := local:get-version-components($version)
  let $schema-query := cts:and-query((
    cts:collection-query($const:TYPE_SCHEMA),
    cts:field-range-query($const:NAMESPACE_KEY, "=", $namespace),
    cts:field-range-query($const:VERSION_MAJOR, "=", map:get($version-components, $const:VERSION_MAJOR))
  ))
  let $schema-uris := cts:uris((),(),$schema-query)
  let $schema-metadata := $schema-uris ! (xdmp:document-get-metadata(.))
  let $version-map := map:map()
  return (
    for $md in $schema-metadata
    return if (map:contains($version-map, $const:VERSION_MINOR))
    then (
      if (map:get($version-map,$const:VERSION_MINOR) lt map:get($md, $const:VERSION_MINOR))
      then for $key in map:keys($md) return map:put($version-map, $key, map:get($md, $key))
      else if (map:get($version-map,$const:VERSION_PATCH) lt map:get($md, $const:VERSION_PATCH))
      then for $key in map:keys($md) return map:put($version-map, $key, map:get($md, $key))
      else ()
    )
    else for $key in map:keys($md) return map:put($version-map, $key, map:get($md, $key)),
    $version-map
  )
};

(:~
 : Function: get-modules
 : this function searches the appropriate versie.xml document matching the schema-name and version
 : the modules contain the xds schema and schematron uris to use
 :
 : @param $schema-uri       uri of the xsd schema in the schemas database
 : @param $schema-version   version of the xsd schema
 : @param $schema-name      the schema-name of the xsd schema in the form of http://....schema.xsd
 : @result sequence of Modules elements matching the input parameters
 :)
declare private function local:get-modules(
  $schema-uri as xs:string,
  $schema-version as xs:string,
  $schema-name as xs:string?
) as item()*
{
  xdmp:trace($TRACE-ID, ("GET_MODULES", "schema-uri", $schema-uri, "schema-version", $schema-version, "schema-name", $schema-name)),
  let $schema-overview := cts:search(fn:doc(), cts:and-query((
    cts:collection-query($const:TYPE_VERSIEOVERZICHT),
    cts:element-value-query(xs:QName("schemata:versie"), $schema-version),
    if (fn:exists($schema-name)) then cts:element-value-query(xs:QName("schemata:schema"), $schema-name) else ()
  )), "unfiltered")
  let $modules := $schema-overview//schemata:Module[descendant::schemata:schema/fn:string() eq $schema-name]
  let $imported-modules :=
    for $loc in fn:doc($schema-uri)/node()/descendant-or-self::xs:import/@schemaLocation/fn:data()
    let $md := xdmp:document-get-metadata($loc)
    let $modules-version := map:get($md, $const:VERSION_KEY)
    let $ns :=  map:get($md, $const:NAMESPACE_KEY)
    let $modules-name := map:get($md, $const:CATALOG_NAME)
    let $modules-overview := cts:search(fn:doc(), cts:and-query((
      cts:collection-query($const:TYPE_VERSIEOVERZICHT),
      cts:element-value-query(xs:QName("schemata:versie"), $modules-version)
    )), "unfiltered")
    return $modules-overview//schemata:Module[descendant::schemata:schema/fn:string() eq $modules-name]

  return (
    xdmp:trace($TRACE-ID, ("found modules:" || fn:count($modules), "found imported-modules:" || fn:count($imported-modules))),
    $modules,
    $imported-modules
  )
};

(:~
 : Function: get-schematrons
 : this function takes all Modules elements and aggregates all schematron files needed to validate the given node
 : filters out unneeded schematrons if the specific element does not occur in the node
 :
 : @param $modules  sequence of Modules elements
 : @param $node     the node to validate
 : @result sequence of schematron uris
 :)
declare private function local:get-schematrons(
  $modules as element()*,
  $node as node()
) as xs:string*
{
  let $schematrons := fn:distinct-values(
    for $mod in $modules
    let $qname := fn:QName($mod/schemata:namespace/fn:data(), $mod/schemata:localName/fn:data())
    where $node/descendant-or-self::*[fn:node-name() eq $qname]
    return $mod//schemata:schematron
  )
  return cts:uris((),(), cts:and-query((
    cts:collection-query($const:TYPE_SCHEMATRON),
    cts:field-range-query("catalogName", "=", $schematrons)
  )))
};
