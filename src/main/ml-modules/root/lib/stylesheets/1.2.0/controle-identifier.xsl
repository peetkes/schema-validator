<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:local="http://localfunctions/opera/akn-join"
                xmlns:common="http://localfunctions/opera/common"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="/lib/stylesheets/1.2.0/common.xsl"/>

  <xsl:variable name="akn" as="xs:string" select="'akn'"/>
  <xsl:variable name="join" as="xs:string" select="'join'"/>
  <xsl:variable name="landen" as="xs:string*" select="('nl','aw','cw','sx')"/>

  <xsl:variable name="work" as="xs:string" select="'werk'"/>
  <xsl:variable name="expression" as="xs:string" select="'expressie'"/>

  <xsl:variable name="typeBesluit" as="xs:string" select="'bill'"/>
  <xsl:variable name="typeKennisgeving" as="xs:string" select="'doc'"/>
  <xsl:variable name="typeRegeling" as="xs:string" select="'act'"/>
  <xsl:variable name="typeOfficialGazette" as="xs:string" select="'officialGazette'"/>
  <xsl:variable name="typeRegdata" as="xs:string" select="'regdata'"/>
  <xsl:variable name="typePubdata" as="xs:string" select="'pubdata'"/>
  <xsl:variable name="typeInfodata" as="xs:string" select="'infodata'"/>
  <xsl:variable name="typeProces" as="xs:string" select="'proces'"/>
  <xsl:variable name="typeStop" as="xs:string" select="'stop'"/>
  <xsl:variable name="documentTypesAkn" as="xs:string*" select="($typeBesluit,$typeKennisgeving,$typeRegeling,$typeOfficialGazette)"/>
  <xsl:variable name="documentTypesJoin" as="xs:string*" select="($typeRegdata, $typePubdata, $typeInfodata, $typeProces, $typeStop)"/>
  <xsl:variable name="soortKennisgevingBesluittermijnen" as="xs:string" select="'KennisgevingBesluittermijnen'"/>
  <xsl:variable name="soortKennisgevingVoorgenomenBesluit" as="xs:string" select="'KennisgevingVoorgenomenBesluit'"/>
  <xsl:variable name="soortKennisgevingUitspraakRechter" as="xs:string" select="'KennisgevingUitspraakRechter'"/>
  <xsl:variable name="soortKennisgeving" as="xs:string+" select="($soortKennisgevingBesluittermijnen, $soortKennisgevingVoorgenomenBesluit, $soortKennisgevingUitspraakRechter)"/>
  <xsl:variable name="authors" as="xs:string*" select="('stb','stcrt','trb','gmb','prb','bgr','wsb')"/>

  <xsl:variable name="bevoegdGezagenAkn" as="xs:string*" select="('koninkrijk','land','gemeente','ministerie','provincie','waterschap')"/>
  <xsl:variable name="bevoegdGezagenJoin" as="xs:string*" select="('consolidatie')"/>

  <xsl:variable name="talen" as="xs:string*" select="('nld','eng','fry','pap','mul','und')"/>

  <xsl:variable name="id-marker" as="xs:string" select="'/'"/>

  <xsl:variable name="akn-start" as="xs:string" select="concat($id-marker, 'akn', $id-marker)"/>
  <xsl:variable name="join-start" as="xs:string" select="concat($id-marker, 'join', $id-marker)"/>

  <!--  Akoma Ntoso Identifiers
    /akn/[country2]/[documentType]/[author]/[date]/[other]/[country3]@[version-info]
    /join/id/[documentType]/[author]/[date]/[other]/[country3]@[version-info]
  -->
  <xsl:function name="local:controle-work-identifier" as="xs:string*">
    <xsl:param name="identifier" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="isLimited" as="xs:boolean"/>

    <xsl:value-of select="local:controle-work-identifier($identifier, $type, $isLimited, false())"/>
  </xsl:function>

  <xsl:function name="local:controle-work-identifier" as="xs:string*">
    <xsl:param name="identifier" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="isLimited" as="xs:boolean"/>
    <xsl:param name="forExpression" as="xs:boolean"/>

    <xsl:variable name="seq" select="tokenize($identifier, $id-marker)"/>

    <!-- akn or join -->
    <xsl:variable name="identifierType" select="local:init-string($seq[2])"/>
    <!-- documentType: [bill/act/doc/officialGazette] for akn, [pubdata/regdata/process/versie] for join-->
    <xsl:variable name="documentType" select="local:init-string($seq[4])"/>
    <xsl:variable name="other" select="local:init-string($seq[7])"/>

    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="$forExpression">
          <xsl:value-of select="concat('[Controleer juiste opbouw ', upper-case($type), ' - expressie - ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('[Controleer juiste opbouw ', upper-case($type), ' - werk - ')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- mogelijke foutmeldingen -->
    <xsl:variable name="errorDocumentType">
      <xsl:choose>
        <xsl:when test="$type = $akn">
          <xsl:value-of select="common:get-message('LVBB2010',(concat($prefix, 'derde string]'), $documentType, $identifier, string-join($documentTypesAkn,',')))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="common:get-message('LVBB2010',(concat($prefix, 'derde string]'), $documentType, $identifier, string-join($documentTypesJoin,',')))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="not($identifierType = $type)">
      <xsl:value-of select="common:get-message('LVBB2008', (concat($prefix, 'eerste string]'), $identifierType, $identifier, $type))"/>
    </xsl:if>
    <xsl:if test="(($type = $akn and not($documentType = $documentTypesAkn)) or ($type = $join and not($documentType = $documentTypesJoin)))">
      <xsl:value-of select="$errorDocumentType"/>
    </xsl:if>
    <xsl:if test="not(local:controle-overig($other))">
      <xsl:value-of select="common:get-message('LVBB2020', (concat($prefix, 'zevende string]'), $other, $identifier))"/>
    </xsl:if>
    <xsl:if test="string-length($other) gt 128">
      <xsl:value-of select="common:get-message('LVBB2021', (concat($prefix, 'zevende string]'),$other, $identifier))"/>
    </xsl:if>

    <xsl:if test="not($isLimited)">
      <!-- country for akn or 'id' for join-->
      <xsl:variable name="country2" select="local:init-string($seq[3])"/>
      <!-- bevoegd gezag -->
      <xsl:variable name="author" select="local:init-string($seq[5])"/>
      <!-- jaar -->
      <xsl:variable name="date" select="local:init-string($seq[6])"/>

      <!-- mogelijke foutmeldingen -->
      <xsl:variable name="errorCountry2">
        <xsl:choose>
          <xsl:when test="$type = $akn">
            <xsl:value-of select="common:get-message('LVBB2009',(concat($prefix, 'tweede string]'), $country2, $identifier, string-join($landen,',')))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="common:get-message('LVBB2009',(concat($prefix, 'tweede string]'), $country2, $identifier, 'id'))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="not($country2 = $landen)">
        <xsl:value-of select="$errorCountry2"/>
      </xsl:if>
      <xsl:if test="($documentType = $typeOfficialGazette and not($author = $authors))">
        <xsl:value-of select="common:get-message('LVBB2022',(concat($prefix, 'bevoegd-gezag]'), $author, $identifier, string-join($authors,',')))"/>
      </xsl:if>
      <xsl:value-of select="local:controle-datum($identifier, $date, $work, $type, $work)"/>
      <xsl:value-of select="local:controle-punt($identifier, $type,$work)"/>
    </xsl:if>
  </xsl:function>

  <!-- Controle expressie identifier -->

  <xsl:function name="local:controle-expression-identifier" as="xs:string*">
    <xsl:param name="identifier" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="isLimited" as="xs:boolean"/>

    <xsl:variable name="seq" select="tokenize($identifier,$id-marker)"/>
    <xsl:variable name="versionInfo" select="tokenize($seq[8],'@')"/>
    <xsl:variable name="taal" select="local:init-string($versionInfo[1])"/>

    <xsl:variable name="taal" select="local:init-string($versionInfo[1])"/>
    <xsl:variable name="versie" select="local:init-string($versionInfo[2])"/>

    <xsl:for-each select="local:controle-work-identifier($identifier, $type, $isLimited, true())">
      <xsl:value-of select="."/>
    </xsl:for-each>

    <xsl:choose>
      <xsl:when test="empty($versie)">
        <xsl:value-of select="common:get-message('LVBB2019',('[Controleer juiste opbouw ', upper-case($type), ' expressie]', $identifier))"/>
      </xsl:when>
      <xsl:when test="$type eq $join">
        <xsl:variable name="datum" select="local:init-string($seq[6])"/>
        <xsl:variable name="versieDelen" select="tokenize($versie, ';')" />
        <xsl:variable name="datumDeel" select="local:init-string($versieDelen[1])" />
        <xsl:variable name="errorDateBefore" select="common:get-message('LVBB2015',('[Controleer juiste opbouw JOIN - expressie - expressie-datum]', $datumDeel, $identifier, $datum))"/>

        <xsl:for-each select="local:controle-datum($identifier, $datumDeel, 'expressie', $join, 'expressie')">
          <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="(string-length($datumDeel) = 4 or string-length($datum) = 4)">
            <xsl:variable name="datumDeelShort" select="substring($datumDeel, 1, 4)"/>
            <xsl:variable name="datumShort" select="substring($datum,1,4)"/>
            <xsl:if test="not($datumDeelShort >= $datumShort)">
              <xsl:value-of select="$errorDateBefore"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not($datumDeel >= $datum)">
              <xsl:value-of select="$errorDateBefore"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="local:controle-taal($identifier, $taal, $type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="local:controle-taal($identifier, $taal, $type)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- controle op taal -->
  <xsl:function name="local:controle-taal" as="xs:string?">
    <xsl:param name="identifier" as="xs:string"/>
    <xsl:param name="taal" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>

    <xsl:if test="not($taal = $talen)">
      <xsl:value-of select="common:get-message('LVBB2016',(concat('[Controleer juiste opbouw ', $type, ' - expressie - taal]'), $taal, $identifier, string-join($talen,',')))"/>
    </xsl:if>
  </xsl:function>

  <!-- controle op voorkomen geen punt -->
  <xsl:function name="local:controle-punt" as="xs:string?">
    <xsl:param name="identifier" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="soort-test" as="xs:string"/>

    <xsl:if test="contains($identifier,'.')">
      <xsl:value-of select="common:get-message('LVBB2017', (concat('[Controleer juiste opbouw ', $type,' - ', $soort-test,']'), $identifier))"/>
    </xsl:if>
  </xsl:function>

  <!-- datum controle -->
  <xsl:function name="local:controle-datum" as="xs:string*">
    <xsl:param name="identifier" as="xs:string"/>
    <xsl:param name="datum" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="soort-test" as="xs:string"/>
    <xsl:param name="deel" as="xs:string"/>

    <!-- mogelijke foutmeldingen -->
    <xsl:variable name="fout-lengte-onjuist" select="common:get-message-with-type('LVBB2013','1',(concat('[Controleer juiste opbouw ',$type,' - ',$soort-test,' - ',$deel,'-datum]'), $deel, $datum, $identifier))"/>
    <xsl:variable name="fout-niet-numeriek" select="common:get-message-with-type('LVBB2013','2',(concat('[Controleer juiste opbouw ',$type,' - ',$soort-test,' - ',$deel,'-datum]'), $deel, $datum, $identifier))"/>
    <xsl:variable name="fout-datum-onjuist" select="common:get-message-with-type('LVBB2013','3',(concat('[Controleer juiste opbouw ',$type,' - ',$soort-test,' - ',$deel,'-datum]'), $deel, $datum, $identifier))"/>

    <xsl:variable name="meldingen" as="xs:string*">
      <xsl:if test="(not(string-length($datum) = 4)) and (not(string-length($datum) = 10))">
        <xsl:value-of select="$fout-lengte-onjuist"/>
      </xsl:if>
      <xsl:if test="(string-length($datum) = 4) and (not($datum castable as xs:integer))">
        <xsl:value-of select="$fout-niet-numeriek"/>
      </xsl:if>
      <xsl:if test="(string-length($datum) = 10) and (not($datum castable as xs:date))">
        <xsl:value-of select="$fout-datum-onjuist"/>
      </xsl:if>
    </xsl:variable>

    <xsl:value-of select="($meldingen)"/>
  </xsl:function>

  <!-- controle op juiste reguliere expressie -->
  <xsl:function name="local:controle-overig" as="xs:boolean">
    <xsl:param name="overig" as="xs:string" />
    <xsl:value-of select="count(analyze-string($overig, '[a-zA-Z0-9][a-zA-Z0-9|_|-]*')//*:non-match) = 0" />
  </xsl:function>

  <!-- initialisatie van een gegeven als string -->
  <xsl:function name="local:init-string" as="xs:string">
    <xsl:param name="input" as="xs:string?" />
    <xsl:choose>
      <xsl:when test="empty($input)">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>