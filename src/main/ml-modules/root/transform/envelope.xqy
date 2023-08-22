xquery version "1.0-ml";
(:~
: User: pkester
: Date: 31/07/2023
: Time: 17:13
:)
module namespace local = "http://koop.overheid.nl/lvbb/transform/envelope";

declare option xdmp:mapping "false";

declare function local:transform(
    $content as map:map,
    $context as map:map
) as map:map*
{
  let $attr-value := (map:get($context, "transform_param"), "oin=oin-1,id-levering=idl-1,id-bevoegdgezag=bg-1")[1]
  let $oin := fn:substring-after(fn:tokenize($attr-value,',')[1], "oin=")
  let $idl := fn:substring-after(fn:tokenize($attr-value,',')[2], "id-levering=")
  let $idbg := fn:substring-after(fn:tokenize($attr-value,',')[3], "id-bevoegdgezag=")
  let $the-doc := map:get($content, "value")
  return
    if (fn:empty($the-doc/element()))
    then $content
    else
      let $root := $the-doc/*
      return (
        map:put($content, "value",
            document {
              $root/preceding-sibling::node(),
              element {fn:name($root)} {
                (:)                attribute { "oin" } {$oin},
                attribute { "idl" } {$idl},
                attribute { "idbg" } {$idbg},:)
                $root/@*,
                $root/node()
              },
              $root/following-sibling::node()
            }
        ), $content
      )
};

    