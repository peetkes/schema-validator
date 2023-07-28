xquery version "1.0-ml";
(:~
: User: pkester
: Date: 27/07/2023
: Time: 17:12
:)
module namespace local = "http://koop.overheid.nl/lvbb/corb/util";

declare namespace cat = "urn:oasis:names:tc:entity:xmlns:xml:catalog";

declare option xdmp:mapping "false";

declare function local:adjust-schemaLocation(
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

declare function local:adjust-location-recurse(
    $origin as xs:string*,
    $new as xs:string*
) as xs:string
{
  if (fn:head($origin) ne "..")
  then fn:string-join(($new, $origin),"/")
  else local:adjust-location-recurse($origin[2 to last()], $new[1 to last()-1])
};

declare private function local:adjust-absolute-location(
    $node as node()
) as item()*
{
  let $original-location := $node/@schemaLocation/fn:string()
  let $catalog-uri := cts:uris((), ("limit=1"), cts:element-attribute-range-query(xs:QName("cat:uri"), xs:QName("name"), "=", $original-location))
  let $prefix := fn:string-join(fn:tokenize($catalog-uri,"/")[1 to last()-1] ,"/")
  let $newLocation := fn:doc($catalog-uri)//cat:uri[@name eq $original-location]/@uri/fn:string()
  return (
    xdmp:trace("koop-corb", fn:concat("--abs--\n",
        $original-location, "\n", $prefix, "/", $newLocation,
        "\n++abs++")
    ),
    xdmp:node-replace($node/@schemaLocation, attribute schemaLocation { fn:concat($prefix, "/",$newLocation) })
  )
};

declare private function local:adjust-relative-location(
    $node as node(),
    $location as xs:string
) as item()*
{
  let $original-location := $node/@schemaLocation/fn:string()
  let $newLocation :=
    if (fn:starts-with($original-location, "./") or fn:not(fn:starts-with($original-location, "../")))
    then fn:concat($location, "/", fn:replace($original-location, "./", ""))
    else local:adjust-location($original-location, $location)
  return (
    xdmp:trace("koop-corb", fn:concat("--rel--\n",
      $original-location, "\n", $newLocation, "\n++rel++")
    ),
    xdmp:node-replace($node/@schemaLocation, attribute schemaLocation { $newLocation })
  )
};

