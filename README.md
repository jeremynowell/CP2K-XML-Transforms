CP2K XML Transforms
===================

Introduction
------------

The project provides transforms for use with CP2K and TempSS. TempSS requires an XML schema (XSD) which defines the input tree representation, and an XML stylesheet (XSLT) to transform the input tree from XML into CP2K compliant input files. Since the potential inputs for CP2K are numerous, the XSD and XSLT would be difficult to produce by hand. This project provides XSLT transforms which take the XML manual produced by CP2K and produce the required XSD and XSLT files automatically.

Pre-requisites
--------------
The project requires
 * Apache Ant
 * Saxon-HE (for XSLT 2.0 support).

Usage
-----

The project is an Apache Ant project. Edit the `build.xml` file to specify the location of the Saxon-HE jar file. Then run:

    ant

to build the XSD and XSLT files.

Inputs are taken from the Input directory and placed into the Output directory.
