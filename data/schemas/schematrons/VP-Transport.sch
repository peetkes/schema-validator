<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xdmp="http://marklogic.com/xdmp"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2" schemaVersion="1.0">

  <sch:title>Check toBG meldingen</sch:title>

  <sch:ns uri="http://www.overheid.nl/2017/lvbb" prefix="lvbb"/>
  <sch:ns uri="http://www.overheid.nl/2017/stop" prefix="stop"/>
  <sch:ns uri="localFunctions" prefix="fct"/>

  <sch:phase id="all">
  </sch:phase>


  <sch:pattern id="check-publicatieVerzoekResultaat">
    <sch:rule context="lvbb:publicatieVerzoekResultaat">
      <sch:assert test="lvbb:verslag" role="warning">Geen verslag aanwezig binnen <sch:name />.</sch:assert>
    </sch:rule>
    
    <sch:rule context="lvbb:publicatieVerzoekResultaat/lvbb:meldingen">
      <sch:report test="true()" role="warning">Meldingen op verkeerde niveau.</sch:report>
    </sch:rule>
    
    <sch:rule context="lvbb:publicatieVerzoekResultaat/lvbb:verslag/lvbb:uitkomst">
      <sch:let name="value" value="/lvbb:publicatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('gepubliceerd', 'niet-valide', 'behandeling-afgebroken')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'gepubliceerd' and $value = 'succes') or (. ne 'gepubliceerd' and $value = 'mislukt')">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-uitkomst [<sch:value-of select="."/>]</sch:assert>
    </sch:rule>

    <sch:rule context="lvbb:publicatieVerzoekResultaat/lvbb:verslag/lvbb:voortgang">
      <sch:let name="value" value="/lvbb:publicatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('validatie-voltooid','registratie-voltooid')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'behandeling-afgebroken' and $value = 'mislukt') or (. ne 'behandeling-afgebroken' and $value = 'succes')" role="warning">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-voortgang [<sch:value-of select="."/>]</sch:assert>      
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="check-validatieVerzoekResultaat">
    <sch:rule context="lvbb:validatieVerzoekResultaat">
      <sch:assert test="lvbb:verslag" role="warning">Geen verslag aanwezig binnen <sch:name />.</sch:assert>
    </sch:rule>
    
    <sch:rule context="lvbb:validatieVerzoekResultaat/lvbb:meldingen">
      <sch:report test="true()" role="warning">Meldingen op verkeerde niveau.</sch:report>
    </sch:rule> 

    <sch:rule context="lvbb:validatieVerzoekResultaat/lvbb:verslag/lvbb:uitkomst">
      <sch:let name="value" value="/lvbb:validatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('valide', 'niet-valide', 'behandeling-afgebroken')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'valide' and $value = 'succes') or (. ne 'valide' and $value = 'mislukt')">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-uitkomst [<sch:value-of select="."/>]</sch:assert>
    </sch:rule>

    <sch:rule context="lvbb:validatieVerzoekResultaat/lvbb:verslag/lvbb:voortgang">
      <sch:let name="value" value="/lvbb:validatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('validatie-voltooid')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'behandeling-afgebroken' and $value = 'mislukt') or (. ne 'behandeling-afgebroken' and $value = 'succes')" role="warning">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-voortgang [<sch:value-of select="."/>]</sch:assert>      
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="check-directeMutatieVerzoekResultaat">
    <sch:rule context="lvbb:directeMutatieVerzoekResultaat">
      <sch:assert test="lvbb:verslag" role="warning">Geen verslag aanwezig binnen <sch:name />.</sch:assert>
    </sch:rule>
    
    <sch:rule context="lvbb:directeMutatieVerzoekResultaat/lvbb:meldingen">
      <sch:report test="true()" role="warning">Meldingen op verkeerde niveau.</sch:report>
    </sch:rule> 

    <sch:rule context="lvbb:directeMutatieVerzoekResultaat/lvbb:verslag/lvbb:uitkomst">
      <sch:let name="value" value="/lvbb:directeMutatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('ok', 'niet-valide')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'ok' and $value = 'succes') or (. ne 'ok' and $value = 'mislukt')">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-uitkomst [<sch:value-of select="."/>]</sch:assert>
    </sch:rule>

    <sch:rule context="lvbb:directeMutatieVerzoekResultaat/lvbb:verslag/lvbb:voortgang">
      <sch:let name="value" value="/lvbb:directeMutatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('validatie-voltooid','mutatie-voltooid')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'behandeling-afgebroken' and $value = 'mislukt') or (. ne 'behandeling-afgebroken' and $value = 'succes')" role="warning">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-voortgang [<sch:value-of select="."/>]</sch:assert>      
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="check-validatieDirecteMutatieVerzoekResultaat">
    <sch:rule context="lvbb:validatieDirecteMutatieVerzoekResultaat">
      <sch:assert test="lvbb:verslag" role="warning">Geen verslag aanwezig binnen <sch:name />.</sch:assert>
    </sch:rule>
    
    <sch:rule context="lvbb:validatieDirecteMutatieVerzoekResultaat/lvbb:meldingen">
      <sch:report test="true()" role="warning">Meldingen op verkeerde niveau.</sch:report>
    </sch:rule> 

    <sch:rule context="lvbb:validatieDirecteMutatieVerzoekResultaat/lvbb:verslag/lvbb:uitkomst">
      <sch:let name="value" value="/lvbb:validatieDirecteMutatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('valide', 'niet-valide')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'valide' and $value = 'succes') or (. ne 'valide' and $value = 'mislukt')">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-uitkomst [<sch:value-of select="."/>]</sch:assert>
    </sch:rule>

    <sch:rule context="lvbb:validatieDirecteMutatieVerzoekResultaat/lvbb:verslag/lvbb:voortgang">
      <sch:let name="value" value="/lvbb:validatieDirecteMutatieVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('validatie-voltooid')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="($value = 'succes')" role="warning">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-voortgang [<sch:value-of select="."/>]</sch:assert>      
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="check-breekPublicatieAfVerzoekResultaat">
    <sch:rule context="lvbb:breekPublicatieAfVerzoekResultaat">
      <sch:assert test="lvbb:verslag" role="warning">Geen verslag aanwezig binnen <sch:name />.</sch:assert>
    </sch:rule>
    
    <sch:rule context="lvbb:breekPublicatieAfVerzoekResultaat/lvbb:meldingen">
      <sch:report test="true()" role="warning">Meldingen op verkeerde niveau.</sch:report>
    </sch:rule> 

    <sch:rule context="lvbb:breekPublicatieAfVerzoekResultaat/lvbb:verslag/lvbb:uitkomst">
      <sch:let name="value" value="/lvbb:breekPublicatieAfVerzoekResultaat/lvbb:uitkomst/string()"/>
      <sch:assert test=". = ('ok', 'behandeling-mislukt')" role="warning"><sch:name/> bevat NIET toegestane waarde [<sch:value-of select="."/>]</sch:assert>      
      <sch:assert test="(. = 'ok' and $value = 'succes') or (. ne 'ok' and $value = 'mislukt')">uitkomst [<sch:value-of select="$value"/>] ongelijk aan verslag-uitkomst [<sch:value-of select="."/>]</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="check-algemeen">
    <sch:rule context="lvbb:verslag">
      <sch:assert test="lvbb:meldingen" role="warning">Geen meldingen aanwezig binnen verslag.</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>