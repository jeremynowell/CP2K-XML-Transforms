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
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Add missing space between numbers -->
  <xsl:template match="DEFAULT_VALUE/text()[.='-5.00000000E-001 1.50000000E+000 5.00000000E-001 5.00000000E-001 1.50000000E+000-5.00000000E-001']">-5.00000000E-001 1.50000000E+000 5.00000000E-001 5.00000000E-001 1.50000000E+000 -5.00000000E-001</xsl:template>
  <xsl:template match="DEFAULT_VALUE/text()[.='-1.00000000E+000-1.00000000E+000']">-1.00000000E+000 -1.00000000E+000</xsl:template>

</xsl:stylesheet>
