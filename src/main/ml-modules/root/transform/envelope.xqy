xquery version "1.0-ml";
(:~
: User: pkester
: Date: 31/07/2023
: Time: 17:13
:)
module namespace local = "http://marklogic.com/schema-validator/transform/envelope";

declare namespace opera = "http:koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "sv-mlcp";

declare function local:creation-date() as element()
{
  let $timestamp := fn:current-dateTime()
  return element opera:creation-date {
    attribute iso-date { fn:adjust-date-to-timezone(xs:date($timestamp), ()) },
    fn:format-dateTime($timestamp, "[D01]-[M01]-[Y0001] [H01]:[m01]:[s01].[f001]")
  }
};
declare function local:update-content(
  $content as map:map,
  $context as map:map,
  $metadata as map:map
) as map:map
{
  let $doc := map:get($content,"value")
  let $node-kind := xdmp:node-kind($doc)
  let $is-binary := $content/node() instance of binary()
  return switch ($node-kind)
    case "document"
    return (
      let $root := $doc/*
      return
        map:put($content, "value", document {
          element opera:envelope {
            element opera:metadata {
              for $key in map:keys($metadata)
              return element { xs:QName(fn:concat("opera:", $key)) } { map:get($metadata, $key) },
              local:creation-date()
            },
            element opera:instance  { $root }
          }
        }),
      $content
    )
    case "binary"
    return (
      xdmp:trace($TRACE-ID, $context),
      let $options := <options xmlns="xdmp:document-insert">
        <permissions>{ map:get($context, "permissions") }</permissions>
        <collections>{
          for $coll in map:get($context, "collections")
          return <collection>{ $coll }</collection>
        }</collections>
        <metadata>{ map:get($context, "metadata") }</metadata>
      </options>
      (:)     xdmp:document-insert(fn:concat(map:get($content,"uri"), ".meta.xml"),
          document {
            element opera:envelope {
              element opera:metadata {
                element opera:binary-uri { map:get($content,"uri") },
                for $key in map:keys($metadata)
                return element { xs:QName(fn:concat("opera:", $key)) } { map:get($metadata, $key) },
                local:creation-date()
              }
            }
          },<options xmlns="xdmp:document-insert">
            <permissions>{ map:get($context, "permissions") }</permissions>
            <collections>{
              for $coll in map:get($context, "collections")
              return <collection>{ $coll }</collection>
            }</collections>
            <metadata>{ map:get($context, "metadata") }</metadata>
          </options>
      ),:)
      return (
        xdmp:trace($TRACE-ID, $options),
        $content
      )
    )
    default
      return $content
};

declare function local:transform(
    $content as map:map,
    $context as map:map
) as map:map*
{
  xdmp:trace($TRACE-ID, "In mlcp transform function"),
  let $attr-value := (map:get($context, "transform_param"), "oin=oin-1,id-levering=idl-1,id-bevoegdgezag=bg-1")[1]
  let $oin := fn:substring-after(fn:tokenize($attr-value,',')[1], "oin=")
  let $idl := fn:substring-after(fn:tokenize($attr-value,',')[2], "id-levering=")
  let $bg := fn:substring-after(fn:tokenize($attr-value,',')[3], "id-bg=")
  let $metadata := json:object()
  =>map:with("oin", $oin)
  =>map:with("id-levering", $idl)
  =>map:with("id-bevoegdgezag", $bg)
  return (
    map:put($context, "metadata", $metadata),
    map:put($context, "collections", (map:get($context, "collections"), fn:concat("opera/oin/",$oin), fn:concat("opera/levering/",$idl), fn:concat("opera/bevoegdgezag/",$bg))),
    local:update-content($content, $context, $metadata)
  )
};
