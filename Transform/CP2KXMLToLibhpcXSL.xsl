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
Convert the CP2K XML manual into a TempSS stylesheet for transforming
TempSS XML into CP2K text files.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:libhpc="http://www.libhpc.imperial.ac.uk/SchemaAnnotation">

  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:include href="CP2KCommonFunctions.xsl"/>

  <xsl:template match="/">
    <xsl:element name="xsl:stylesheet">
      <xsl:namespace name="xsl" select="'http://www.w3.org/1999/XSL/Transform'"/>
      <xsl:attribute name="version">2.0</xsl:attribute>

      <xsl:element name="xsl:output">
        <xsl:attribute name="method">text</xsl:attribute>
        <xsl:attribute name="indent">no</xsl:attribute>
        <xsl:attribute name="omit-xml-declaration">yes</xsl:attribute>
      </xsl:element>

      <xsl:element name="xsl:strip-space">
        <xsl:attribute name="elements">*</xsl:attribute>
      </xsl:element>

      <xsl:element name="xsl:template">
        <xsl:attribute name="match">/</xsl:attribute>
        <xsl:apply-templates select="CP2K_INPUT" mode="apply"/>
      </xsl:element>

      <xsl:apply-templates select="CP2K_INPUT" mode="template"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CP2K_INPUT" mode="apply">
    <xsl:element name="xsl:apply-templates">
      <xsl:attribute name="select">CP2K</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CP2K_INPUT" mode="template">
    <xsl:element name="xsl:template">
      <xsl:attribute name="match">CP2K</xsl:attribute>
      <!--<xsl:apply-templates select="SECTION" mode="apply"/>-->
      <xsl:element name="xsl:apply-templates"/>
    </xsl:element>

    <xsl:element name="xsl:template">
      <xsl:attribute name="match">CP2K_KEYWORD_SECTION_PARAMETERS</xsl:attribute>
      <xsl:element name="xsl:text">
        <xsl:value-of select="'&amp;#32;'" disable-output-escaping="yes"/>
      </xsl:element>
      <xsl:element name="xsl:value-of">
        <xsl:attribute name="select">
          <xsl:value-of select="'.'"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:element>

    <xsl:element name="xsl:template">
      <xsl:attribute name="match">*</xsl:attribute>
      <xsl:element name="xsl:value-of">
        <xsl:attribute name="select">local-name(.)</xsl:attribute>
      </xsl:element>
      <xsl:element name="xsl:text"> </xsl:element>
      <xsl:element name="xsl:value-of">
        <xsl:attribute name="select">.</xsl:attribute>
      </xsl:element>
    </xsl:element>

    <xsl:apply-templates select="SECTION">
      <xsl:with-param name="path">CP2K</xsl:with-param>
      <xsl:with-param name="indent" select="0"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="SECTION">
    <xsl:param name="trueName" select="NAME"/>
    <xsl:param name="safeName" select="libhpc:makeNameSafe($trueName, 'SECTION')"/>
    <xsl:param name="path">./</xsl:param>
    <xsl:param name="indentText" select="''"/>
    <xsl:param name="newPath" select="concat($path, '/', $safeName)"/>
    <xsl:element name="xsl:template">
      <xsl:attribute name="match">
        <xsl:value-of select="$newPath"/>
      </xsl:attribute>
      <xsl:element name="xsl:text">
        <xsl:value-of select="$indentText" disable-output-escaping="yes"/>
        <xsl:value-of select="'&amp;amp;'" disable-output-escaping="yes"/>
        <xsl:value-of select="$trueName"/>
      </xsl:element>
      <xsl:element name="xsl:apply-templates">
        <xsl:attribute name="select">CP2K_KEYWORD_SECTION_PARAMETERS</xsl:attribute>
      </xsl:element>
      <xsl:element name="xsl:text">
        <xsl:value-of select="'&amp;#13;&amp;#10;'" disable-output-escaping="yes"/>
      </xsl:element>
      <xsl:element name="xsl:apply-templates">
        <xsl:attribute name="select">node() except CP2K_KEYWORD_SECTION_PARAMETERS</xsl:attribute>
      </xsl:element>
      <xsl:element name="xsl:text">
        <xsl:value-of select="$indentText" disable-output-escaping="yes"/>
        <xsl:value-of select="'&amp;amp;END&amp;#32;'" disable-output-escaping="yes"/>
        <xsl:value-of select="$trueName"/>
        <xsl:value-of select="'&amp;#13;&amp;#10;'" disable-output-escaping="yes"/>
      </xsl:element>
    </xsl:element>

    <xsl:apply-templates select="DEFAULT_VALUE"/>
    <xsl:apply-templates select="DESCRIPTION"/>
    <xsl:apply-templates select="SECTION_PARAMETERS"/>
    <xsl:apply-templates select="DEFAULT_KEYWORD">
      <xsl:with-param name="path" select="$newPath"/>
      <xsl:with-param name="indentText" select="libhpc:addIndent($indentText)"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="KEYWORD">
      <xsl:with-param name="path" select="$newPath"/>
      <xsl:with-param name="indentText" select="libhpc:addIndent($indentText)"/>
    </xsl:apply-templates>
    <!-- Sections can contain sections -->
    <xsl:apply-templates select="SECTION">
      <xsl:with-param name="path" select="$newPath"/>
      <xsl:with-param name="indentText" select="libhpc:addIndent($indentText)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="SECTION_PARAMETERS | DEFAULT_VALUE | DESCRIPTION">
  </xsl:template>

  <xsl:template match="DEFAULT_UNIT">
    <xsl:element name="xsl:text">
      <xsl:value-of select="'['" disable-output-escaping="yes"/>
    </xsl:element>
    <xsl:element name="xsl:value-of">
      <xsl:attribute name="select">
        <xsl:value-of select="'@UNIT'"/>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="xsl:text">
      <xsl:value-of select="']'" disable-output-escaping="yes"/>
      <xsl:value-of select="'&amp;#32;'" disable-output-escaping="yes"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="KEYWORD">
    <xsl:param name="trueName" select="NAME[@type='default']"/>
    <xsl:param name="safeName" select="libhpc:makeNameSafe($trueName, 'KEYWORD')"/>
    <xsl:param name="path">./</xsl:param>
    <xsl:param name="newPath" select="concat($path, '/', $safeName)"/>
    <xsl:param name="indentText" select="''"/>
    <xsl:element name="xsl:template">
      <xsl:attribute name="match">
        <xsl:value-of select="$newPath"/>
      </xsl:attribute>
      <xsl:element name="xsl:text">
        <xsl:value-of select="$indentText" disable-output-escaping="yes"/>
        <xsl:value-of select="$trueName"/>
        <xsl:value-of select="'&amp;#32;'" disable-output-escaping="yes"/>
      </xsl:element>
      <xsl:apply-templates select="DEFAULT_UNIT"/>
      <xsl:element name="xsl:value-of">
        <xsl:attribute name="select">
          <xsl:value-of select="'.'"/>
        </xsl:attribute>
      </xsl:element>

      <xsl:element name="xsl:text">
        <xsl:value-of select="'&amp;#13;&amp;#10;'" disable-output-escaping="yes"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- Like KEYWORD but don't output the keyword, only the value -->
  <xsl:template match="DEFAULT_KEYWORD">
    <xsl:param name="trueName" select="NAME[@type='default']"/>
    <xsl:param name="safeName" select="libhpc:makeNameSafe($trueName, 'KEYWORD')"/>
    <xsl:param name="path">./</xsl:param>
    <xsl:param name="newPath" select="concat($path, '/', $safeName)"/>
    <xsl:param name="indentText" select="''"/>
    <xsl:element name="xsl:template">
      <xsl:attribute name="match">
        <xsl:value-of select="$newPath"/>
      </xsl:attribute>
      <xsl:element name="xsl:text">
        <xsl:value-of select="$indentText" disable-output-escaping="yes"/>
        <xsl:value-of select="'&amp;#32;'" disable-output-escaping="yes"/>
      </xsl:element>
      <xsl:element name="xsl:value-of">
        <xsl:attribute name="select">
          <xsl:value-of select="'.'"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="xsl:text">
        <xsl:value-of select="'&amp;#13;&amp;#10;'" disable-output-escaping="yes"/>
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
