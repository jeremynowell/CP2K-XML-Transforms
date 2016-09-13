<?xml version="1.0" encoding="UTF-8"?>
<!--
 Copyright (c) 2016 The University of Edinburgh

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<!--
Convert the CP2K XML manual into a TempSS XML schema for specifying
TempSS XML input tree.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:libhpc="http://www.libhpc.imperial.ac.uk/SchemaAnnotation">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:include href="CP2KCommonFunctions.xsl"/>

  <!-- Create an "enum" for all available DATA_TYPE kind values -->
  <xsl:variable name="DataType.keyword" select="'keyword'"/>
  <xsl:variable name="DataType.logical" select="'logical'"/>
  <xsl:variable name="DataType.string" select="'string'"/>
  <xsl:variable name="DataType.integer" select="'integer'"/>
  <xsl:variable name="DataType.word" select="'word'"/>
  <xsl:variable name="DataType.real" select="'real'"/>

  <!-- Enum for different list types -->
  <xsl:variable name="List.integer" select="'integerList'"/>
  <xsl:variable name="List.string" select="'stringList'"/>
  <xsl:variable name="List.real" select="'realList'"/>

  <xsl:template match="/">
    <!-- Write start of XSD, including simpleType definitions -->
    <xsl:element name="xs:schema">
      <xsl:namespace name="libhpc" select="'http://www.libhpc.imperial.ac.uk/SchemaAnnotation'"/>
      <xsl:namespace name="" select="'http://www.libhpc.imperial.ac.uk'"/>
      <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
      <xsl:attribute name="targetNamespace">http://www.libhpc.imperial.ac.uk</xsl:attribute>
      <xsl:attribute name="elementFormDefault">qualified</xsl:attribute>
      <xsl:attribute name="xsi:schemaLocation">http://www.libhpc.imperial.ac.uk LibhpcSchemaAnnotation.xsd</xsl:attribute>

      <xsl:element name="xs:simpleType">
        <xsl:attribute name="name">boolean</xsl:attribute>
        <xsl:element name="xs:restriction">
          <xsl:attribute name="base">xs:string</xsl:attribute>
          <xsl:element name="xs:enumeration">
            <xsl:attribute name="value">T</xsl:attribute>
          </xsl:element>
          <xsl:element name="xs:enumeration">
            <xsl:attribute name="value">F</xsl:attribute>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="xs:simpleType">
        <xsl:attribute name="name"><xsl:value-of select="$List.integer"/></xsl:attribute>
        <xsl:element name="xs:list">
          <xsl:attribute name="itemType">xs:integer</xsl:attribute>
        </xsl:element>
      </xsl:element>

      <xsl:element name="xs:simpleType">
        <xsl:attribute name="name"><xsl:value-of select="$List.string"/></xsl:attribute>
        <xsl:element name="xs:list">
          <xsl:attribute name="itemType">xs:string</xsl:attribute>
        </xsl:element>
      </xsl:element>

      <xsl:element name="xs:simpleType">
        <xsl:attribute name="name"><xsl:value-of select="$List.real"/></xsl:attribute>
        <xsl:element name="xs:list">
          <xsl:attribute name="itemType">xs:float</xsl:attribute>
        </xsl:element>
      </xsl:element>

      <xsl:apply-templates select="CP2K_INPUT"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CP2K_INPUT">
    <xsl:element name="xs:element">
      <xsl:attribute name="name">CP2K</xsl:attribute>
        <xsl:element name="xs:complexType">
          <xsl:element name="xs:annotation">
            <xsl:element name="xs:appinfo">
              <xsl:element name="libhpc:documentation">
                <xsl:value-of select="CP2K_VERSION"/> compiled on <xsl:value-of select="COMPILE_DATE"/> using <xsl:value-of select="COMPILE_REVISION"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="xs:sequence">
            <xsl:apply-templates select="SECTION"/>
          </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="SECTION">
    <xsl:param name="name" select="NAME"/>
    <xsl:element name="xs:element">
      <xsl:attribute name="name">
        <xsl:value-of select="libhpc:makeNameSafe($name, 'SECTION')"/>
      </xsl:attribute>
      <xsl:attribute name="libhpc:trueName">
        <xsl:value-of select="$name"/>
      </xsl:attribute>
      <xsl:call-template name="required"/>
      <xsl:apply-templates select="@repeats"/>
      <xsl:apply-templates select="DEFAULT_VALUE"/>
      <xsl:apply-templates select="DESCRIPTION"/>
      <xsl:element name="xs:complexType">
        <xsl:element name="xs:sequence">
          <xsl:apply-templates select="SECTION_PARAMETERS"/>
          <xsl:apply-templates select="DEFAULT_KEYWORD"/>
          <xsl:apply-templates select="KEYWORD"/>
          <xsl:apply-templates select="SECTION"/>
        </xsl:element>
        <xsl:element name="xs:attribute">
          <xsl:attribute name="name">
            <xsl:text>trueName</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="required">
  <!-- Required is not a reliable indicator at the moment, make everything optional
    <xsl:param name="required" select="."/>
    <xsl:choose>
      <xsl:when test="$required = 'yes'">
        <xsl:attribute name="minOccurs">1</xsl:attribute>
      </xsl:when>
      <xsl:when test="$required = 'no'">
        <xsl:attribute name="minOccurs">0</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          WARNING: Unrecognised value of attribute "required": <xsl:value-of select="$required"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    -->
    <xsl:attribute name="minOccurs">0</xsl:attribute>
  </xsl:template>

  <xsl:template match="@repeats">
    <xsl:param name="repeats" select="."/>
    <xsl:choose>
      <xsl:when test="$repeats = 'yes'">
        <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
      </xsl:when>
      <xsl:when test="$repeats = 'no'">
        <xsl:attribute name="maxOccurs">1</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          WARNING: Unrecognised value of attribute "repeats": <xsl:value-of select="$repeats"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="DEFAULT_VALUE">
    <xsl:attribute name="default">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="DESCRIPTION">
    <xsl:element name="xs:annotation">
      <xsl:element name="xs:appinfo">
        <xsl:element name="libhpc:documentation">
          <xsl:value-of disable-output-escaping="no" select="."/>
        </xsl:element>
        <!-- Get units if they exist -->
        <xsl:if test="../DEFAULT_UNIT">
          <!-- Make the unit editable rather than fixed -->
          <xsl:element name="libhpc:editableUnits">
            <xsl:value-of select="../DEFAULT_UNIT"/>
          </xsl:element>
        </xsl:if>
        <xsl:apply-templates select="../NAME[@type='alias']"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="NAME[@type='alias']">
    <xsl:element name="libhpc:alias">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="SECTION_PARAMETERS | DEFAULT_KEYWORD | KEYWORD">
    <xsl:param name="kind" select="DATA_TYPE/@kind"/>
    <!-- Only use default name, ignore aliases -->
    <xsl:param name="name" select="NAME[@type='default']"/>
    <xsl:element name="xs:element">
      <xsl:attribute name="name">
        <xsl:value-of select="libhpc:makeNameSafe($name, 'KEYWORD')"/>
      </xsl:attribute>
      <xsl:attribute name="libhpc:trueName">
        <xsl:value-of select="$name"/>
      </xsl:attribute>
      <xsl:call-template name="required"/>
      <xsl:apply-templates select="@repeats"/>
      <xsl:apply-templates select="DEFAULT_VALUE"/>
      <xsl:apply-templates select="DATA_TYPE"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="DATA_TYPE">
    <xsl:param name="kind" select="@kind"/>
    <xsl:param name="nVar" select="N_VAR"/>
    <xsl:choose>
      <xsl:when test="$kind = $DataType.keyword">
        <xsl:apply-templates select="../DESCRIPTION"/>
        <xsl:choose>
          <xsl:when test="$nVar != 1">
            <xsl:message terminate="no">
              WARNING: Multiple enumeration unhandled for data type <xsl:value-of select="$kind"/>!
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="ENUMERATION"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$kind = $DataType.logical">
        <xsl:choose>
          <xsl:when test="$nVar != 1">
            <xsl:message terminate="no">
              WARNING: Multiple values unhandled for data type <xsl:value-of select="$kind"/>!
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">boolean</xsl:attribute>
            <xsl:apply-templates select="../DESCRIPTION"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$kind = $DataType.string">
        <xsl:choose>
          <xsl:when test="$nVar != 1">
            <xsl:message terminate="no">
              WARNING: Multiple values unhandled for data type <xsl:value-of select="$kind"/>!
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">xs:string</xsl:attribute>
            <xsl:apply-templates select="../DESCRIPTION"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$kind = $DataType.integer">
        <xsl:choose>
          <xsl:when test="$nVar = -1">
            <xsl:apply-templates select="../DESCRIPTION"/>
            <xsl:element name="xs:simpleType">
              <xsl:element name="xs:restriction">
                <xsl:attribute name="base"><xsl:value-of select="$List.integer"/></xsl:attribute>
                <xsl:element name="xs:minLength">
                  <xsl:attribute name="value">1</xsl:attribute>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$nVar > 1">
            <xsl:apply-templates select="../DESCRIPTION"/>
            <xsl:element name="xs:simpleType">
              <xsl:element name="xs:restriction">
                <xsl:attribute name="base"><xsl:value-of select="$List.integer"/></xsl:attribute>
                <xsl:element name="xs:length">
                  <xsl:attribute name="value"><xsl:value-of select="$nVar"/></xsl:attribute>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$nVar = 1">
            <xsl:attribute name="type">xs:integer</xsl:attribute>
            <xsl:apply-templates select="../DESCRIPTION"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="no">
              WARNING: Multiple values unhandled for data type <xsl:value-of select="$kind"/>!
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$kind = $DataType.word">
        <xsl:choose>
          <xsl:when test="$nVar = -1">
            <xsl:apply-templates select="../DESCRIPTION"/>
            <xsl:element name="xs:simpleType">
              <xsl:element name="xs:restriction">
                <xsl:attribute name="base"><xsl:value-of select="$List.string"/></xsl:attribute>
<!--
                <xsl:element name="xs:minLength">
                  <xsl:attribute name="value">1</xsl:attribute>
                </xsl:element>
-->
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$nVar > 1">
            <xsl:apply-templates select="../DESCRIPTION"/>
            <xsl:element name="xs:simpleType">
              <xsl:element name="xs:restriction">
                <xsl:attribute name="base"><xsl:value-of select="$List.string"/></xsl:attribute>
                <xsl:element name="xs:length">
                  <xsl:attribute name="value"><xsl:value-of select="$nVar"/></xsl:attribute>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$nVar = 1">
            <xsl:attribute name="type">xs:string</xsl:attribute>
            <xsl:apply-templates select="../DESCRIPTION"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="no">
              WARNING: Multiple values unhandled for data type <xsl:value-of select="$kind"/>!
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$kind = $DataType.real">
        <xsl:choose>
          <xsl:when test="$nVar = -1">
            <xsl:apply-templates select="../DESCRIPTION"/>
            <xsl:element name="xs:simpleType">
              <xsl:element name="xs:restriction">
                <xsl:attribute name="base"><xsl:value-of select="$List.real"/></xsl:attribute>
                <xsl:element name="xs:minLength">
                  <xsl:attribute name="value">1</xsl:attribute>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$nVar > 1">
            <xsl:apply-templates select="../DESCRIPTION"/>
            <xsl:element name="xs:simpleType">
              <xsl:element name="xs:restriction">
                <xsl:attribute name="base"><xsl:value-of select="$List.real"/></xsl:attribute>
                <xsl:element name="xs:length">
                  <xsl:attribute name="value"><xsl:value-of select="$nVar"/></xsl:attribute>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$nVar = 1">
            <xsl:attribute name="type">xs:float</xsl:attribute>
            <xsl:apply-templates select="../DESCRIPTION"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="no">
              WARNING: Multiple values unhandled for data type <xsl:value-of select="$kind"/>!
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          WARNING: Unmatched DATA_TYPE kind: <xsl:value-of select="$kind" />
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ENUMERATION">
    <xsl:element name="xs:simpleType">
      <xsl:element name="xs:restriction">
        <xsl:attribute name="base">xs:string</xsl:attribute>
        <xsl:for-each select="ITEM">
          <xsl:element name="xs:enumeration">
            <xsl:attribute name="value">
              <xsl:value-of select="NAME"/>
            </xsl:attribute>
            <xsl:apply-templates select="DESCRIPTION"/>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*">
    <xsl:message terminate="no">
      WARNING: Unmatched element: <xsl:value-of select="name()"/>
    </xsl:message>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- Prevent auto copying of all text. See:
        http://stackoverflow.com/questions/3360017/why-does-xslt-output-all-text-by-default
  -->
  <xsl:template match="text()|@*">
  </xsl:template>

</xsl:stylesheet>
