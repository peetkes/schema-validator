xquery version "1.0-ml";
module namespace local = "http://marklogic.com/schema-validator/lib/utilities/datum-utilities";

import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0.1-nodoc.xqy";

declare option xdmp:mapping "false";

(: Geeft per feestdag(en) de offset(s) weer ten opzichte van Paaszondag :)
declare private variable $PAASZONDAG-OFFSETS := map:map()
  => map:with("PASEN", (xs:dayTimeDuration("P0D"), xs:dayTimeDuration("P1D")))
  => map:with("HEMELVAART", (xs:dayTimeDuration("P39D")))
  => map:with("PINKSTEREN", (xs:dayTimeDuration("P49D"), xs:dayTimeDuration("P50D")))
  ;
declare private variable $MAX-ITERATIONS as xs:int := 100;

(:~
 : Gebruik de offsets en de datum van Paaszondag om te bepalen of de
 : opgegeven datum een variabele feestdag is.
 :
 : @param $datum                    te bevragen datum
 : @param $sleutel                  sleutel voor offsets t.o.v. Paaszondag
 : @param $paaszondag               datum paaszondag
 :
 : @return                          true/false
 :)
declare private function local:is-variabele-feestdag-tov-pasen(
  $datum as xs:date,
  $sleutel as xs:string,
  $paaszondag as xs:date
) as xs:boolean
{
	if (map:contains($PAASZONDAG-OFFSETS, $sleutel))
	then
	  some $offset in map:get($PAASZONDAG-OFFSETS, $sleutel) satisfies $datum eq $paaszondag + $offset
	else
	  fn:error("ONGELDIGE-OFFSET-TOV-PASEN", "Ongeldig sleutel voor offsets t.o.v. Pasen", ($datum, $sleutel, $paaszondag))
};

(:~
 : Is de opgegeven datum een van de Paasdagen?
 :
 : @param $datum                    te bevragen datum
 : @param $paaszondag               datum paaszondag
 :
 : @return                          true/false
 :)
declare private function local:is-pasen(
  $datum as xs:date,
  $paaszondag as xs:date
)
{
  local:is-variabele-feestdag-tov-pasen($datum, "PASEN", $paaszondag)
};

(:~
 : Is de opgegeven datum een van de Pinksterdagen?
 :
 : @param $datum                    te bevragen datum
 : @param $paaszondag               datum paaszondag
 :
 : @return                          true/false
 :)
declare private function local:is-pinksteren(
  $datum as xs:date,
  $paaszondag as xs:date
)
{
  local:is-variabele-feestdag-tov-pasen($datum, "PINKSTEREN", $paaszondag)
};

(:~
 : Is de opgegeven datum Hemelvaartsdag?
 :
 : @param $datum                    te bevragen datum
 : @param $paaszondag               datum paaszondag
 :
 : @return                          true/false
 :)
declare private function local:is-hemelvaart(
  $datum as xs:date,
  $paaszondag as xs:date
)
{
  local:is-variabele-feestdag-tov-pasen($datum, "HEMELVAART", $paaszondag)
};

(:~
 : Bepaal de datum van Paaszondag voor het opgegeven jaar volgende de methode van Gauss,
 : zie https://nl.wikipedia.org/wiki/Paas-_en_pinksterdatum
 :
 : @param $jaar                     jaar waarvoor Paaszondag bepaald moet worden
 :
 : @return                          datum van Paaszondag
 :)
declare function local:paaszondag(
  $jaar as xs:int
) as xs:date
{
  let $g := ($jaar mod 19) + 1
  let $c := fn:floor($jaar div 100) + 1
  let $x := fn:floor((3 * $c) div 4) - 12
  let $y := fn:floor((8 * $c + 5) div 25) - 5
  let $z := fn:floor((5 * $jaar) div 4) - 10 - $x
  let $e :=
    let $t  := (11 * $g + 20 + $y - $x) mod 30
    return
      if ($t eq 24 or ($t eq 25 and $g > 11)) then $t + 1 else $t
  let $n :=
    let $t := 44 - $e
    return if ($t < 21) then ($t + 30) else $t
  let $d := $n + 7 - (($z + $n) mod 7)
  let $dag-maand := if ($d > 31) then ($d - 31, 4) else ($d, 3)

  return
    xs:date(
      concat(
        functx:pad-integer-to-length(xs:integer($jaar),4),'-',
        functx:pad-integer-to-length(xs:integer($dag-maand[2]),2),'-',
        functx:pad-integer-to-length(xs:integer($dag-maand[1]),2)
      )
  )
};

(:~
 : Bepaal of de opgegeven datum op een weekdag valt, d.w.z. niet op zater- of zondag.
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-weekdag(
  $datum as xs:date
) as xs:boolean
{
  (: 0 = zondag, 1 = maandag, ..., 6 = zaterdag :)
  (functx:day-of-week(fn:adjust-date-to-timezone($datum, ())) mod 6) != 0
};

(:~
 : Bepaal of de opgegeven datum een feestdag is die op een vaste dag in het jaar valt,
 : zoals Nieuwjaar, Koningsdag of een van de Kerstdagen. Het is tevens een feestdag
 : op bevrijdingsdag mits het jaartal deelbaar is door 5
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-vaste-feestdag(
  $datum as xs:date
) as xs:boolean
{
  local:is-nieuwjaarsdag($datum) or
    local:is-koningsdag($datum) or
    (local:is-bevrijdingsdag($datum) and (fn:year-from-date($datum) mod 5) eq 0) or
    local:is-kerstmis($datum)
};

(:~
 : Bepaal of de opgegeven datum Nieuwjaarsdag is
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-nieuwjaarsdag(
  $datum as xs:date
) as xs:boolean
{
  fn:day-from-date($datum) eq 1 and fn:month-from-date($datum) eq 1
};

(:~
 : Bepaal of de opgegeven datum Koningsdag is
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-koningsdag(
  $datum as xs:date
) as xs:boolean
{
  fn:day-from-date($datum) eq 27 and fn:month-from-date($datum) eq 4
};

(:~
 : Bepaal of de opgegeven datum Bevrijdingsdag is
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-bevrijdingsdag(
  $datum as xs:date
) as xs:boolean
{
  fn:day-from-date($datum) eq 5 and fn:month-from-date($datum) eq 5
};

(:~
 : Bepaal of de opgegeven datum een van de Kerstdagen is
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-kerstmis(
  $datum as xs:date
) as xs:boolean
{
  fn:day-from-date($datum) = (25,26) and fn:month-from-date($datum) eq 12
};

(:~
 : Bepaal of de opgegeven datum een feestdagen is die op een wisselende
 : dag in het jaar valt, d.w.z. een van de feestdagen die afhankelijk is van
 : Paaszondag (Pasen, Hemelvaart en Pinksteren).
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-variabele-feestdag(
  $datum as xs:date
) as xs:boolean
{
  let $maand-jaar := fn:format-date($datum, '[M01][D01]')
  let $is-variabele-feestdag :=
    if ($maand-jaar ge '0323' and $maand-jaar le '0614')  (: Vroegste paasmaandag 23 maart, laatste pinkstermaandag 14 juni :)
    then
      let $jaar := fn:year-from-date($datum)
      let $paas-zondag := local:paaszondag($jaar)
      return local:is-pasen($datum, $paas-zondag) or local:is-hemelvaart($datum, $paas-zondag) or local:is-pinksteren($datum, $paas-zondag)
    else fn:false()
  return $is-variabele-feestdag
};


(:~
 : Is de opgegeven datum een van de Paasdagen?
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-pasen(
  $datum as xs:date
)
{
  let $paaszondag := local:paaszondag(fn:year-from-date($datum))
  return local:is-pasen($datum, $paaszondag)
};

(:~
 : Is de opgegeven datum een van de Pinksterdagen?
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-pinksteren(
  $datum as xs:date
)
{
  let $paaszondag := local:paaszondag(fn:year-from-date($datum))
  return local:is-pinksteren($datum, $paaszondag)
};


(:~
 : Is de opgegeven datum een van de Hemelvaartsdag?
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-hemelvaart(
  $datum as xs:date
)
{
  let $paaszondag := local:paaszondag(fn:year-from-date($datum))
  return local:is-hemelvaart($datum, $paaszondag)
};

(:~
 : Is de opgegeven datum een werkdag? Dat wil zeggen:
 : - vallend op een weekdag
 : - niet vallend op een vaste feestdag (Nieuwjaarsdag, Koningsdag, Kerstmis etc.)
 : - niet vallend op een wisselende feestdag (Pasen, Pinksteren, Hemelvaart)
 :
 : @param $datum                    te bevragen datum
 :
 : @return                          true/false
 :)
declare function local:is-werkdag(
  $datum as xs:date
) as xs:boolean
{
  local:is-weekdag($datum) and not(local:is-vaste-feestdag($datum)) and not(local:is-variabele-feestdag($datum))
};

(:~
 : Bepaal de eerst-mogelijke werkdag op of na de opgegeven datum
 :
 : @param $peildatum                peildatum of huidige datum indien leeg
 :
 : @return                          eerstvolgende werkdag op of na peildatum
 :)
declare function local:eerste-werkdag(
  $peildatum as xs:date?
) as xs:date
{
  let $d := if (fn:exists($peildatum)) then $peildatum else fn:current-date()
  return local:eerste-werkdag(fn:adjust-date-to-timezone($d, ()), 0)
};

(:~
 : Bepaal de eerst-mogelijke werkdag, breek af met fout als teveel recursies nodig zijn
 :
 : @param $peildatum                peildatum of huidige datum indien leeg
 : @param $level                    niveau recursie
 :
 : @return                          eerstvolgende werkdag op of na peildatum
 :)
declare private function local:eerste-werkdag(
  $peildatum as xs:date,
  $level as xs:int
) as xs:date
{
  if ($level gt $MAX-ITERATIONS)
  then fn:error(xs:QName("GEEN-WERKDAG-GEVONDEN"), "Geen werkdag gevonden", ($peildatum, $level))
  else
      if (local:is-werkdag($peildatum))
      then $peildatum
      else local:eerste-werkdag($peildatum + xs:dayTimeDuration("P1D"), $level + 1)
};