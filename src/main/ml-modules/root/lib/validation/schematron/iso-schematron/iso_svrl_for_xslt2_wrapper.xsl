<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
        xmlns:exsl="http://exslt.org/common"
        extension-element-prefixes="exsl"
        version="2.0">

  <xsl:import href="/MarkLogic/schematron/iso-schematron/iso_svrl_for_xslt2.xsl"/>

  <xsl:template name="processing-instruction">
    <xsl:copy-of select="./processing-instruction()" />
  </xsl:template>

  <xsl:template name="process-prolog">
    <xsl:call-template name="processing-instruction"/>
    <!--
      This is used to pass in a parameter map which can be used inside the schematron rules
      Param parameters is a map with key value items that can be used in the schematron rules.
      To access values from the map you should use map:get($parameters,'key').
      Make sure to add the following namespace definition into your schematron file:
      <sch:ns prefix="map" uri="http://marklogic.com/xdmp/map"/>
    -->
    <axsl:param name="parameters"/>

    <axsl:output method="xml" omit-xml-declaration="no" standalone="yes"
                 indent="yes">
      <xsl:if test=" string-length($output-encoding) &gt; 0">
        <xsl:attribute name="encoding"><xsl:value-of select=" $output-encoding" /></xsl:attribute>
      </xsl:if>
    </axsl:output>

  </xsl:template>

</xsl:stylesheet>