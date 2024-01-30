<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <sch:ns uri="http://localfuctions/opera/common" prefix="common"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:p>Versie 3.2.1</sch:p>
  <xsl:include href="/projects/opera/repos/opera/contexts/cds/resource/stylesheets/common.xsl"/>
  <!--

 

        - The schematron file implements the validation of the restricted

        - subset of GML 3.2 defined in the GML simple features profile

        - compliance level SF2. The scope of the validation consists of

        - GML document instances. Validation of the restricted subset of

        - XML Schema, defined in the same profile document, is not

        - implemented by this schematron file.

    

-->
  <sch:pattern>
    <sch:rule context="/*/*/*">
      <!-- Rule to exclude metadataProperty -->
      <sch:assert test="not(gml:metaDataProperty)"><sch:value-of select="common:store-error('LVBB3002','This profile prohibits use of gml:metaDataProperty elements for referencing metadata in instance documents.')"/>
			</sch:assert>
    </sch:rule>
    <sch:rule context="gml:Node">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','Node mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Edge">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','Edge mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Face">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','Face mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TopoSolid">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TopoSolid mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TopoPoint">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TopoPoint mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TopoCurve">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TopoCurve mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TopoSurface">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TopoSurface mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TopoVolume">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TopoVolume mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TopoComplex">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TopoComplex mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Curve">
      <sch:assert test="gml:segments[gml:LineStringSegment|gml:Arc|gml:Circle|gml:CircleByCenterPoint]"><sch:value-of select="common:store-error('LVBB3002','Curve moet juiste segments bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:OrientableSurface">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','OrientableSurface mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:CompositeSurface">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','CompositeSurface mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:PolyhedralSurface">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','PolyhedralSurface mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Tin">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','Tin mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:TriangulatedSurface">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','TriangulatedSurface mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Solid">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','Solid mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:MultiSolid">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','MultiSolid mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:CompositeSolid">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','CompositeSolid mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:CompositeCurve">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','CompositeCurve mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Grid">
      <sch:assert test="'1'='1'"><sch:value-of select="common:store-error('LVBB3002','Grid mag niet vorkomen')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Point">
      <sch:assert test="gml:pos"><sch:value-of select="common:store-error('LVBB3002','Point moet element pos bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:CircleByCenterPoint">
      <sch:assert test="gml:pos or gml:radius"><sch:value-of select="common:store-error('LVBB3002','CircleByCenterPoint moet element pos of radius bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:LineStringSegment">
      <sch:assert test="gml:posList"><sch:value-of select="common:store-error('LVBB3002','LineStringSegment moet element posList bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:LinearRing">
      <sch:assert test="gml:posList"><sch:value-of select="common:store-error('LVBB3002','LinearRing moet element posList bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Arc">
      <sch:assert test="gml:posList"><sch:value-of select="common:store-error('LVBB3002','Arc moet element posList bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Circle">
      <sch:assert test="gml:posList"><sch:value-of select="common:store-error('LVBB3002','Circle moet element posList bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:MultiPoint">
      <sch:assert test="not(gml:pointMembers)"><sch:value-of select="common:store-error('LVBB3002','MultiPoint mag geen element pointMembers bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:MultiCurve">
      <sch:assert test="not(gml:curveMembers)"><sch:value-of select="common:store-error('LVBB3002','MultiCurve mag geen element curveMembers bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:MultiSurface">
      <sch:assert test="not(gml:surfaceMembers)"><sch:value-of select="common:store-error('LVBB3002','MultiSurface mag geen element surfaceMembers bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:MultiGeometry">
      <sch:assert test="not(gml:geometryMembers)"><sch:value-of select="common:store-error('LVBB3002','MultiGeometry mag geen element geometryMembers bevatten')"/></sch:assert>
    </sch:rule>
    <sch:rule context="gml:Surface/gml:patches">
      <sch:assert test="gml:PolygonPatch"><sch:value-of select="common:store-error('LVBB3002','Surface/patches moet een element PolygonPatch bevatten')"/></sch:assert>
    </sch:rule>
    <!-- sch:rule context="/*//*" -->
    <!-- Rule to exclude spatial topology types -->
    <!-- sch:assert test="not(self::gml:Node|self::gml:Edge|self::gml:Face|self::gml:TopoSolid|self::gml:TopoPoint|self::gml:TopoCurve|self::gml:TopoSurface|self::gml:TopoVolume|self::gml:TopoComplex)">

                Spatial properties are limited to the set of geometric

                types consisting of point, curve with linear and/or

                circular arc interpolation, planar surface, or aggregates

                thereof. Spatial topology is excluded.

			</sch:assert -->
    <!-- Rule for content of curves -->
    <!-- sch:assert test="not(self::gml:Curve) or self::gml:Curve/gml:segments[gml:LineStringSegment|gml:Arc|gml:Circle|gml:CircleByCenterPoint]">

                Curves (standalone or within surfaces) must have linear

                and/or circular arc interpolation (LineString, Curve with

                Arc, Circle or CircleByCenterpoint segments)

			</sch:assert -->
    <!-- Rule for constraints on planar surfaces -->
    <!-- sch:assert test="not(self::gml:OrientableSurface|self::gml:CompositeSurface|self::gml:PolyhedralSurface|self::gml:Tin|self::gml:TriangulatedSurface)">

                Planar surface types are restricted to Polygon or Surface

                elements.

			</sch:assert -->
    <!-- Rule for constraints on GeometryPropertyType -->
    <!-- sch:assert test="not(self::gml:Solid|self::gml:MultiSolid|self::gml:CompositeSolid|self::gml:CompositeCurve|self::gml:Grid)">

                Supported geometry types are restricted to point, curve with 

                linear and/or circular arc interpolation, planar surface,

                or aggregates thereof.

			</sch:assert -->
    <!--

 Rule for geometry coordinates of points and circles by

                centerpoint 

-->
    <!-- sch:assert test="count(self::gml:Point/gml:pos) = count(self::gml:Point/*)">

                Geometry coordinates shall only be specified using the gml:pos element for

                gml:Point.

			</sch:assert -->
    <!-- sch:assert test="count(self::gml:CircleByCenterPoint/gml:pos|self::gml:CircleByCenterPoint/gml:radius) = count(self::gml:CircleByCenterPoint/*)">

                Geometry coordinates shall only be specified using the gml:pos

                element for gml:CircleByCenterPoint.

			</sch:assert -->
    <!--

 Rules for geometry coordinates in geometries other than points 

-->
    <!-- sch:assert test="count(self::gml:LineStringSegment/gml:posList) =                 count(self::gml:LineStringSegment/*)">

                Geometry coordinates shall only be specified using the gml:posList

                element for gml:LineStringSegment.

			</sch:assert>

			<sch:assert test="count(self::gml:LinearRing/gml:posList) =                 count(self::gml:LinearRing/*)">

                Geometry coordinates shall only be specified using the gml:posList

                element for gml:LinearRing.

			</sch:assert>

			<sch:assert test="count(self::gml:Arc/gml:posList) = count(self::gml:Arc/*)">

                Geometry coordinates shall only be specified using the gml:posList

                element for gml:Arc.

			</sch:assert>

			<sch:assert test="count(self::gml:Circle/gml:posList) =                 count(self::gml:Circle/*)">

                Geometry coordinates shall only be specified using the gml:posList

                element for gml:Circle.

			</sch:assert -->
    <!-- Rules for aggregate geometry types -->
    <!-- sch:assert test="not(self::gml:MultiPoint/gml:pointMembers)">

                This profile restricts instance documents to using the property

                container gml:pointMember for the MultiPoint geometry type.

			</sch:assert>

			<sch:assert test="not(self::gml:MultiCurve/gml:curveMembers)">

                This profile restricts instance documents to using the property

                container gml:curveMember for the MultiCurve geometry type.

			</sch:assert>

			<sch:assert test="not(self::gml:MultiSurface/gml:surfaceMembers)">

                This profile restricts instance documents to using the property

                container gml:surfaceMember for the MultiSurface geometry type.

			</sch:assert>

			<sch:assert test="not(self::gml:MultiGeometry/gml:geometryMembers)">

                This profile restricts instance documents to using the property

                container gml:geometryMember for the MultiGeometry geometry type.

			</sch:assert -->
    <!-- Rule for content of surfaces -->
    <!-- sch:assert test="count(self::gml:Surface/gml:patches/gml:PolygonPatch) =                 count(self::gml:Surface/gml:patches/*)">

                The content of gml:Surface elements is restricted to

                gml:PolygonPatch patches.

			</sch:assert>

			<sch:assert test="not(self::*/@srsDimension > 3)">

                Coordinate reference systems may have 1, 2 or 3 dimensions.

			</sch:assert -->
    <!-- /sch:rule -->
  </sch:pattern>
</sch:schema>