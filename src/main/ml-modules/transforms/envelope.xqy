xquery version "1.0-ml";
module namespace transform = "http://marklogic.com/rest-api/transform/envelope";

import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";
import module namespace helper="http://marklogic.com/schema-validator/lib/validation/helper" at "/lib/validation/helper.xqy";
import module namespace env="http://marklogic.com/schema-validator/lib/envelope/envelope" at "/lib/envelope/envelope.xqy";

declare namespace opera = "http://koop.overheid.nl/lvbb/opera";

declare option xdmp:mapping "false";

declare variable $TRACE-ID as xs:string := "sv-transform";
declare variable $eval-options as map:map := map:map()
=>map:with("isolation", "same-statement")
=>map:with("update", "false");

declare function transform:creation-date() as element()
{
  let $timestamp := fn:current-dateTime()
  return element opera:creation-date {
    attribute iso-date { fn:adjust-date-to-timezone(xs:date($timestamp), ()) },
    fn:format-dateTime($timestamp, "[D01]-[M01]-[Y0001] [H01]:[m01]:[s01].[f001]")
  }
};

declare function transform:envelope-xml(
  $node as node(),
  $params as map:map
) as document-node()
{
  document {
    env:create($node, $params)
  }
};

declare function transform:transform(
  $context as map:map,
  $params as map:map,
  $content as document-node()
  ) as document-node()
{
  xdmp:trace($TRACE-ID, ("ENVELOPE", "context", $context, "params", $params)),
  let $node-kind := xdmp:node-kind($content)
  let $mimetype := map:get($context,"input-type")
  return (
    xdmp:trace($TRACE-ID, ("ENVELOPE:mimetype:" || $mimetype)),
    switch($mimetype)
    case $const:mimetype-gml
    return (
      xdmp:trace($TRACE-ID, ("ENVELOPE::gml", xdmp:describe($content))),
      $content
    )
    case $const:mimetype-xml
    return (
      xdmp:trace($TRACE-ID, ("ENVELOPE::xml", xdmp:describe($content))),
      transform:envelope-xml(xdmp:unquote(xdmp:binary-decode($content,"UTF-8"))/node(), $params)
    )
    case $const:mimetype-jpeg
    case $const:mimetype-png
    return (
      xdmp:trace($TRACE-ID, ("ENVELOPE::image", xdmp:describe($content))),
      $content
    )
    default
    return (
      xdmp:trace($TRACE-ID, ("ENVELOPE::default", xdmp:describe($content))),
      $content
    )
  )
};
