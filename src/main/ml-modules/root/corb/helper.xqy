xquery version "1.0-ml";
(:~
: User: pkester
: Date: 27/07/2023
: Time: 17:12
:)
module namespace local = "http://marklogic.com/schema-validator/corb/helper";

declare namespace cat = "urn:oasis:names:tc:entity:xmlns:xml:catalog";
declare namespace sch="http://purl.oclc.org/dsdl/schematron";

declare option xdmp:mapping "false";
declare variable $TRACE-ID as xs:string := "sv-corb";

declare function local:adjust-schema-location(
    $uri as xs:string
) as item()*
{
  let $doc := fn:doc($uri)
  let $nodes := $doc//(xs:import|xs:include)
  let $location := fn:string-join(fn:tokenize($uri,"/")[1 to last()-1],"/")
  for $node in $nodes
  let $is-absolute := fn:matches($node/@schemaLocation/fn:string(), "^(https?://|/)")
  return
    if ($is-absolute)
    then local:adjust-absolute-location($node)
    else local:adjust-relative-location($node, $location)
};

declare function local:adjust-schematron-location(
    $uri as xs:string
) as item()*
{
  let $doc := fn:doc($uri)
  let $nodes := $doc//(sch:include)
  let $location := fn:string-join(fn:tokenize($uri,"/")[1 to last()-1],"/")
  for $node in $nodes
  let $is-absolute := fn:matches($node/@href/fn:string(), "^(https?://|/)")
  return
    if ($is-absolute)
    then local:adjust-absolute-href($node)
    else local:adjust-relative-href($node, $location)
};

declare function local:get-catalog-name-for-uri(
  $uri as xs:string,
  $version as xs:string?
) as xs:string?
{
  xdmp:trace($TRACE-ID, ("get-catalog-name-for-uri", "uri", $uri, "version", $version)),
  let $path := fn:tokenize($uri, "/")
  let $file := $path[last()]
  let $catalog-map := local:find-catalog-uri($path[1 to last() - 1], $file, $version)
  return
    if (fn:exists($catalog-map))
    then  fn:doc(map:get($catalog-map,"catalog-uri"))//cat:uri[@uri eq map:get($catalog-map,"uri")]/@name/fn:data()
    else ()
};

(: ----------------------------
 : PRIVATE FUNCTIONS
 :)

declare private function local:adjust-absolute-location(
    $node as node()
) as item()*
{
  let $original-location := $node/@schemaLocation/fn:string()
  let $catalog-uri := cts:uris((), ("limit=1"),
    cts:element-attribute-range-query(xs:QName("cat:uri"), xs:QName("name"), "=", $original-location))
  let $prefix := fn:string-join(fn:tokenize($catalog-uri,"/")[1 to last()-1] ,"/")
  let $new-location := fn:doc($catalog-uri)//cat:uri[@name eq $original-location]/@uri/fn:string()
  return (
    xdmp:trace($TRACE-ID, fn:concat("--abs--\n",
        $original-location, "\n", $prefix, "/", $new-location,
        "\n++abs++")
    ),
    xdmp:node-replace($node/@schemaLocation,
      attribute schemaLocation { fn:concat($prefix, "/",$new-location) })
  )
};

declare private function local:adjust-relative-location(
    $node as node(),
    $location as xs:string
) as item()*
{
  let $original-location := $node/@schemaLocation/fn:string()
  let $new-location :=
    if (fn:starts-with($original-location, "./") or fn:not(fn:starts-with($original-location, "../")))
    then fn:concat($location, "/", fn:replace($original-location, "./", ""))
    else local:adjust-location($original-location, $location)
  return (
    xdmp:trace($TRACE-ID, fn:concat("--rel--\n",
      $original-location, "\n", $new-location, "\n++rel++")
    ),
    xdmp:node-replace($node/@schemaLocation, attribute schemaLocation { $new-location })
  )
};

declare private function local:adjust-absolute-href(
    $node as node()
) as item()*
{
  let $original-href := $node/@href/fn:string()
  let $catalog-uri := cts:uris((), ("limit=1"),
    cts:element-attribute-range-query(xs:QName("cat:uri"), xs:QName("name"), "=", $original-href))
  let $prefix := fn:string-join(fn:tokenize($catalog-uri,"/")[1 to last()-1] ,"/")
  let $new-href := fn:doc($catalog-uri)//cat:uri[@name eq $original-href]/@uri/fn:string()
  return (
    xdmp:trace($TRACE-ID, fn:concat("--abs--\n",
        $original-href, "\n", $prefix, "/", $new-href,
        "\n++abs++")
    ),
    xdmp:node-replace($node/@href,
      attribute href { fn:concat($prefix, "/",$new-href) })
  )
};

declare private function local:adjust-relative-href(
    $node as node(),
    $href as xs:string
) as item()*
{
  let $original-href := $node/@href/fn:string()
  let $new-href :=
    if (fn:starts-with($original-href, "./") or fn:not(fn:starts-with($original-href, "../")))
    then fn:concat($href, "/", fn:replace($original-href, "./", ""))
    else local:adjust-location($original-href, $href)
  return (
    xdmp:trace($TRACE-ID, fn:concat("--rel--\n",
      $original-href, "\n", $new-href, "\n++rel++")
    ),
    xdmp:node-replace($node/@href, attribute href { $new-href })
  )
};

declare private function local:adjust-location(
    $org as xs:string,
    $new as xs:string
) as xs:string
{
  let $org-split := fn:tokenize($org, "/")
  let $new-split := fn:tokenize($new, "/")
  return
    if (fn:count(fn:filter(function($a) { $a eq ".." }, $org-split)) gt fn:count($new-split)-1)
    then fn:error(xs:QName("LOCATION"),"org does not match new", ($org, $new))
    else local:adjust-location-recurse($org-split, $new-split)
};

declare private function local:adjust-location-recurse(
    $origin as xs:string*,
    $new as xs:string*
) as xs:string
{
  if (fn:head($origin) ne "..")
  then fn:string-join(($new, $origin),"/")
  else local:adjust-location-recurse($origin[2 to last()], $new[1 to last()-1])
};

declare private function local:find-catalog-uri(
  $path as xs:string*,
  $file as xs:string,
  $version as xs:string?
) as map:map?
{
  if (fn:empty($path))
  then ()
  else
    let $catalog-uri := cts:uris((),(), local:query-name($file, $version))
    return
      if (fn:exists($catalog-uri))
      then (xdmp:trace($TRACE-ID, ("find-catalog-uri","path", $path, "file", $file, "version", $version)),
        map:map()
        =>map:with("uri", $file)
        =>map:with("catalog-uri", $catalog-uri)
      )
      else local:find-catalog-uri($path[1 to last() -1], fn:concat($path[last()], "/", $file), $version)
};

declare private function local:query-name(
  $uri as xs:string,
  $version as xs:string?
) as cts:query
{
  cts:and-query((
    cts:collection-query("type/catalog"),
    cts:element-attribute-range-query(xs:QName("cat:uri"), xs:QName("uri"), "=", $uri),
    cts:or-query((
      cts:document-query(cts:uri-match(fn:concat("*/", $version,"/*catalog.xml"))),
      cts:document-query(cts:uri-match("*/extern-catalog.xml"))
    ))

  ))
};

