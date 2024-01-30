xquery version "1.0-ml";
(: Copyright (c) 2020 MarkLogic Corporation :)
module namespace local = "http://marklogic.com/schema-validator/lib/constants";

declare variable $OPTION_SCHEMA as xs:string := "/opera/options/schema";
declare variable $OPTION_SCHEMATRON as xs:string := "/opera/options/schematron";
declare variable $OPTION_VALIDATIEPLAN as xs:string := "/opera/options/validatieplan";

declare variable $TYPE_SCHEMA as xs:string := "type/schema";
declare variable $TYPE_SCHEMATRON as xs:string := "type/schematron";
declare variable $TYPE_VALIDATIEPLAN as xs:string := "type/validatieplan";
declare variable $TYPE_CATALOG as xs:string := "type/catalog";
declare variable $TYPE_VERSIEOVERZICHT as xs:string := "type/versieoverzicht";

declare variable $NAMESPACE_KEY as xs:string := "namespace";
declare variable $VERSION_KEY as xs:string := "version";
declare variable $VERSION_MAJOR as xs:string := "major";
declare variable $VERSION_MINOR as xs:string := "minor";
declare variable $VERSION_PATCH as xs:string := "patch";
declare variable $CATALOG_NAME as xs:string := "catalogName";

declare variable $prefix-collection-besluit as xs:string := "/opera/besluit"; (: id begint met een "/" :)
declare variable $prefix-collection-kennisgeving as xs:string := "/opera/kennisgeving"; (: id begint met een "/" :)
declare variable $prefix-collection-regeling as xs:string := "/opera/regeling"; (: id begint met een "/" :)
declare variable $prefix-collection-informatieobject as xs:string := "/opera/informatieobject"; (: id begint met een "/" :)

declare variable $prefix-collection-oin as xs:string := "/opera/oin/";
declare variable $prefix-collection-idlevering as xs:string := "/opera/idlevering/";
declare variable $prefix-collection-subitem as xs:string := "/opera/subitem/";
declare variable $prefix-collection-doel as xs:string := "/opera/doel"; (: id doel begint met een "/" :)
declare variable $prefix-collection-publicatie as xs:string := "/opera/publicatie/";
declare variable $prefix-collection-xpo as xs:string := "/opera/xpo/";
declare variable $prefix-collection-xpo-opdrachttype as xs:string := "/opera/xpo/opdrachttype/";
declare variable $prefix-collection-xpo-last-status as xs:string := "/opera/xpo/last-status/";
declare variable $prefix-collection-gml as xs:string := "/opera/gml/";
declare variable $prefix-collection-externe-bijlage as xs:string := "/opera/externe-bijlage/";
declare variable $prefix-collection-ow-bestand as xs:string := "/opera/ow-bestand/";
declare variable $prefix-collection-gml-id as xs:string := "/opera/gml-id/";
declare variable $prefix-collection-naam-publicatie as xs:string := "/opera/naam-publicatie/";

declare variable $collection-aanlevering-bestanden as xs:string := "/opera/options/aanlevering";
declare variable $collection-regeling as xs:string := "/opera/document/regeling/werk";
declare variable $collection-versie as xs:string := "/opera/document/regeling/expressie";

declare variable $opdracht-xml as xs:string := "opdracht.xml";
declare variable $manifest-xml as xs:string := "manifest.xml";

declare variable $mimetype-gml as xs:string := "application/gml+xml";
declare variable $mimetype-xml as xs:string := "application/xml";
declare variable $mimetype-png as xs:string := "image/png";
declare variable $mimetype-jpeg as xs:string := "image/jpeg";
declare variable $mimetype-images as xs:string+ := ($mimetype-png, $mimetype-jpeg);

declare function local:collection-besluit-werk($val as xs:string) as xs:string { $prefix-collection-besluit || $val };
declare function local:collection-besluit-expressie($val as xs:string) as xs:string { $prefix-collection-besluit || $val };
declare function local:collection-kennisgeving-werk($val as xs:string) as xs:string { $prefix-collection-kennisgeving || $val };
declare function local:collection-kennisgeving-expressie($val as xs:string) as xs:string { $prefix-collection-kennisgeving || $val };
declare function local:collection-regeling-werk($val as xs:string) as xs:string { $prefix-collection-regeling || $val };
declare function local:collection-regeling-expressie($val as xs:string) as xs:string { $prefix-collection-regeling || $val };
declare function local:collection-informatieobject-werk($val as xs:string) as xs:string { $prefix-collection-informatieobject || $val };
declare function local:collection-informatieobject-expressie($val as xs:string) as xs:string { $prefix-collection-informatieobject || $val };

declare function local:collection-oin($val as xs:string) as xs:string { $prefix-collection-oin || $val };
declare function local:collection-idlevering($val as xs:string) as xs:string { $prefix-collection-idlevering || $val };
declare function local:collection-subitem($val as xs:string) as xs:string { $prefix-collection-subitem || $val };
declare function local:collection-doel($val as xs:string) as xs:string { $prefix-collection-doel || $val };
declare function local:collection-publicatie($val as xs:string) as xs:string { "/opera/publicatie/" || $val };
declare function local:collection-xpo($val as xs:string) as xs:string { "/opera/xpo/" || $val };
declare function local:collection-xpo-opdrachttype($val as xs:string) as xs:string { "/opera/xpo/opdrachttype/" || $val };
declare function local:collection-xpo-last-status($val as xs:string) as xs:string { "/opera/xpo/last-status/" || $val };
declare function local:collection-io-werk($val as xs:string) as xs:string { "/opera/informatieobject/werk/" || $val };
declare function local:collection-io-expressie($val as xs:string) as xs:string { "/opera/informatieobject/expressie/" || $val };
