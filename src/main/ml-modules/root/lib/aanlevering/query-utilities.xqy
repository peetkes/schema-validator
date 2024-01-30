xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/aanlevering/query-utilities";

import module namespace const = "http://marklogic.com/schema-validator/lib/constants" at "/lib/constants.xqy";

declare option xdmp:mapping "false";

(:~
 : Maakt een query die alle bestanden van een aanlevering met 'oin' 'idlevering'
 :
 : @param $oin                       id van de opdrachtgever (bevoegd gezag)
 : @param $idlevering                id van de levering
 :
 : @return                           query van de collecties voor de regisseur bij publicatie
 :)
declare function local:aanlevering-bestanden(
  $oin as xs:string,
  $idlevering as xs:string
) as cts:query
{
  cts:and-query((
    const:collection-oin($oin),
    const:collection-idlevering($idlevering),
    cts:collection-query($const:collection-aanlevering-bestanden)
  ))
};

(:~
 : Query voor het selecteren van bestand met een bepaalde naam binnen de bestanden die de regisseur hanteert
 : voor de invoer bij publicatie
 :
 : @param $oin                       id van de opdrachtgever (bevoegd gezag)
 : @param $idlevering                id van de levering
 : @paran $naam-bestand              naam van het bestand
 :
 : @return                           query die het opdrachtbestand van een aanlevering oplevert
 :)
declare function local:aanlevering-bestand(
        $oin as xs:string,
        $idlevering as xs:string,
        $naam-bestand as xs:string
) as cts:query
{
  cts:and-query((
    const:collection-oin($oin),
    const:collection-idlevering($idlevering),
    cts:collection-query($const:collection-aanlevering-bestanden),
    cts:document-query(cts:uri-match(fn:concat("*/",$naam-bestand)))
  ))
};
