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
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:libhpc="http://www.libhpc.imperial.ac.uk/SchemaAnnotation">

  <!--
  Turns a CP2K given name into one that is XML compliant.
  Prepends CP2K_SECTION_ or CP2K_KEYWORD.
  Replaces + with _.
  -->
  <xsl:function name="libhpc:makeNameSafe">
    <xsl:param name="inputName" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:value-of select="replace((concat('CP2K_', $type, '_', $inputName)), '\+', '_')"/>
  </xsl:function>

  <!--
  Adds a level of indentation for readability.
  -->
  <xsl:function name="libhpc:addIndent">
    <xsl:param name="indentText"/>
    <xsl:value-of select="concat($indentText, '&amp;#32;&amp;#32;')" disable-output-escaping="yes"/>
  </xsl:function>

</xsl:stylesheet>
