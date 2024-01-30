<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xml:lang="en" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink">
  <sch:title>Additionele schematron constraints voor GML / ISO 19136</sch:title>
  <sch:ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="geo" uri="https://standaarden.overheid.nl/stop/imop/geo/"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="basisgeo" uri="http://www.geostandaarden.nl/basisgeometrie/1.0"/>
  <sch:ns uri="http://localfuctions/opera/akn-join" prefix="akn-join"/>
  <sch:ns prefix="common" uri="http://localfuctions/opera/common"/>
  <sch:ns prefix="fct" uri="localFunctions"/>
  <xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/controle-akn-join.xsl"/>
  <!-- Controles AKN aanvullend: controle op 'regdata' binnen join -->
  <sch:pattern name="Controles AKN aanvullend 'regdata'">
    <sch:rule context="/geo:GeoInformatieObjectVaststelling/geo:vastgesteldeVersie/geo:GeoInformatieObjectVersie/geo:FRBRWork |                             /geo:GeoInformatieObjectVaststelling/geo:vastgesteldeVersie/geo:GeoInformatieObjectVersie/geo:FRBRExpression">
      <sch:let name="identificatie" value="./string()"/>
      <sch:let name="reeks" value="tokenize($identificatie,'/')"/>
      <sch:let name="type" value="$reeks[4]"/>
      <!-- mogelijke fout -->
      <sch:let name="fout-geen-gio" value="common:store-error('LVBB1518',concat('[Gml - Controleer Inhoud Identificatie] Waarde van type ',$type,' binnen ',$identificatie,' is niet gelijk aan ',$type-gio))"/>
      <sch:assert test="$type = $type-gio"><sch:value-of select="$fout-geen-gio"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- elke opsomming van coordinaten moet in een parent element een attribuut 'srsName' hebben -->
  <!-- indien in een parent element een srsDimension is opgegeven dan mag die alleen de waarde 2 hebben -->
  <sch:pattern id="sch_vp_geometrie_1">
    <sch:title>Controleer gml element heeft srsName en juiste srsDimension</sch:title>
    <sch:rule context="//basisgeo:geometrie/*">
      <sch:let name="text" value="fct:get-text(.)"/>
      <sch:let name="parent-id" value="../../basisgeo:id/string()"/>
      <sch:let name="srs-missing" value="fct:check-srs(.,$text)"/>
      <sch:let name="dimension" value="fct:check-dimension(.,$text)"/>
      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-srs-missend" value="common:store-error('LVBB3003',concat('[Controleer gml element heeft srsName] Binnen Geometrie met id ',$parent-id,' is er geen srsName opgegeven voor de reeks(en) : ',string-join($srs-missing,', ')))"/>
      <sch:let name="fout-dimension-onjuist" value="common:store-error('LVBB3003',concat('[Controleer gml element heeft juiste srsDimension] Binnen Geometrie met id ',$parent-id,' is er een srsDimension ongelijk aan 2 opgegeven voor de reeks(en) : ',string-join($dimension,', ')))"/>
      <sch:assert test="empty($srs-missing)"><sch:value-of select="$fout-srs-missend"/></sch:assert>
      <sch:assert test="empty($dimension)"><sch:value-of select="$fout-dimension-onjuist"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="sch_vp_geometrie_2">
    <sch:title>posList rules</sch:title>
    <sch:rule context="gml:posList">
      <sch:let name="gml-id" value="ancestor::*[@gml:id][1]/@gml:id/string()"/>
      <sch:let name="posList" value="normalize-space(string(.))"/>
      <!-- mogelijke foutmeldingen -->
      <sch:let name="fout-posList-empty" value="common:store-error('LVBB3012',concat('[Controleer gml element heeft content] Lege gml:posList in gml met gml:id ',$gml-id))"/>
      <sch:assert test="string-length($posList) gt 0"><sch:value-of select="$fout-posList-empty"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  <xsl:function name="fct:check-srs" as="xs:string*">
    <xsl:param name="node" as="node()"/>
		<xsl:param name="parent-text" as="xs:string?"/>
		<xsl:choose>
      <xsl:when test="empty($node/@srsName)">
				<xsl:for-each select="$node/node()">
					<xsl:if test=". instance of element() or (. instance of text() and string-length(normalize-space(.)) gt 0)">
						<xsl:variable name="text" select="fct:get-text(.)"/>
						<xsl:variable name="new-text">
							<xsl:choose>
		<xsl:when test="not(empty($text))">
									<xsl:choose>
		    <xsl:when test="not(empty($parent-text))">
											<xsl:value-of select="concat($parent-text, ' -&gt; ',$text)"/>
										</xsl:when>
		    <xsl:otherwise>
											<xsl:value-of select="$text"/>
										</xsl:otherwise>
		  </xsl:choose>
								</xsl:when>
		<xsl:otherwise>
									<xsl:value-of select="$parent-text"/>
								</xsl:otherwise>
	      </xsl:choose>
						</xsl:variable>
						<xsl:choose>
	      <xsl:when test=". instance of text()">
								<xsl:value-of select="$new-text"/>
							</xsl:when>
	      <xsl:otherwise>
								<xsl:value-of select="fct:check-srs(.,$new-text)"/>
							</xsl:otherwise>
	    </xsl:choose>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
    </xsl:choose>
    </xsl:function>
  <xsl:function name="fct:check-dimension" as="xs:string*">
    <xsl:param name="node" as="node()"/>
		<xsl:param name="parent-text" as="xs:string?"/>
		<xsl:choose>
      <xsl:when test="not(empty($node/@srsDimension))">
				<xsl:if test="not($node/@srsDimension='2')">
					<xsl:value-of select="$parent-text"/>
				</xsl:if>
			</xsl:when>
      <xsl:otherwise>
				<xsl:for-each select="$node/node()">
					<xsl:if test=". instance of element()">
						<xsl:variable name="text" select="fct:get-text(.)"/>
						<xsl:variable name="new-text">
							<xsl:choose>
		<xsl:when test="not(empty($text))">
									<xsl:choose>
		    <xsl:when test="not(empty($parent-text))">
											<xsl:value-of select="concat($parent-text, ' -&gt; ',$text)"/>
										</xsl:when>
		    <xsl:otherwise>
											<xsl:value-of select="$text"/>
										</xsl:otherwise>
		  </xsl:choose>
								</xsl:when>
		<xsl:otherwise>
									<xsl:value-of select="$parent-text"/>
								</xsl:otherwise>
	      </xsl:choose>
						</xsl:variable>
						<xsl:value-of select="fct:check-dimension(.,$new-text)"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="fct:get-text" as="xs:string?">
    <xsl:param name="node" as="node()"/>
		<xsl:if test="not(empty($node/@gml:id))">
			<xsl:value-of select="concat(name($node),' met gml:id ',$node/@gml:id)"/>
		</xsl:if>
	</xsl:function>
</sch:schema>