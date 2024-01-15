xquery version "1.0-ml";
(: Copyright (c) 2020 MarkLogic Corporation :)
module namespace local = "http://marklogic.com/schema-validator/lib/validation/helper";

declare option xdmp:mapping "false";

declare variable $version-pattern as xs:string := "^(\d+)\.(\d+)\.(\d+.*)$";

declare variable $TYPE_SCHEMA as xs:string := "type/schema";

declare variable $NAMESPACE_KEY as xs:string := "namespace";
declare variable $VERSION_KEY as xs:string := "version";
declare variable $VERSION_MAJOR as xs:string := "major";
declare variable $VERSION_MINOR as xs:string := "minor";
declare variable $VERSION_PATCH as xs:string := "patch";

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
  =>map:with($VERSION_KEY, $version)
  =>map:with($VERSION_MAJOR, fn:replace($version, $version-pattern, "$1"))
  =>map:with($VERSION_MINOR, fn:replace($version, $version-pattern, "$2"))
  =>map:with($VERSION_PATCH, fn:replace($version, $version-pattern, "$3"))
  else map:map()
  =>map:with($VERSION_KEY, $version)
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
    cts:collection-query($TYPE_SCHEMA),
    cts:field-range-query($NAMESPACE_KEY, "=", $namespace),
    cts:field-range-query($VERSION_KEY, "=", map:get($version-components, $VERSION_KEY))
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
 : @param  $document  document to get the distinct namespaces for
 : @result sequence of all distinct namespaces used in the document
 :)
declare function local:get-namespaces-in-scope(
  $document as node()
) as xs:string*
{
  fn:distinct-values(
    for $element in $document//*
    for $prefix in fn:in-scope-prefixes($element)[not(. = ('xml','opera'))]
    return fn:namespace-uri-for-prefix($prefix, $element)
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
    cts:collection-query($TYPE_SCHEMA),
    cts:field-range-query($NAMESPACE_KEY, "=", $namespace),
    cts:field-range-query($VERSION_MAJOR, "=", map:get($version-components, $VERSION_MAJOR))
  ))
  let $schema-uris := cts:uris((),(),$schema-query)
  let $schema-metadata := $schema-uris ! (xdmp:document-get-metadata(.))
  let $version-map := map:map()
  return (
    for $md in $schema-metadata
    return if (map:contains($version-map, $VERSION_MINOR))
    then (
      if (map:get($version-map,$VERSION_MINOR) lt map:get($md, $VERSION_MINOR))
      then for $key in map:keys($md) return map:put($version-map, $key, map:get($md, $key))
      else if (map:get($version-map,$VERSION_PATCH) lt map:get($md, $VERSION_PATCH))
      then for $key in map:keys($md) return map:put($version-map, $key, map:get($md, $key))
      else ()
    )
    else for $key in map:keys($md) return map:put($version-map, $key, map:get($md, $key)),
    $version-map
  )
};
