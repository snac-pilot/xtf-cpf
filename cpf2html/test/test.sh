#!/bin/sh
TESTDIR=`dirname $0`
cd $TESTDIR
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/brewerBS.xml -xsl:../cpf2html.xsl -o:test1.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/CompagniedAcadie.xml -xsl:../cpf2html.xsl -o:test2.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/cpf.brown723.xml -xsl:../cpf2html.xsl -o:test3.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/example01.xml -xsl:../cpf2html.xsl -o:test4.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/example05.xml -xsl:../cpf2html.xsl -o:test5.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/example06.xml -xsl:../cpf2html.xsl -o:test6.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/Example10.xml -xsl:../cpf2html.xsl -o:test7.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/Gorki.xml -xsl:../cpf2html.xsl -o:test8.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/Lemoyne.xml -xsl:../cpf2html.xsl -o:test9.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/mawsonBS.xml -xsl:../cpf2html.xsl -o:test10.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/mawsonCollocated.xml -xsl:../cpf2html.xsl -o:test11.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/Odeon.xml -xsl:../cpf2html.xsl -o:test12.html
java -cp ../libs/saxon9he.jar net.sf.saxon.Transform -s:http://www3.iath.virginia.edu/eac/cpf/examples/gregoryXVI.xml -xsl:../cpf2html.xsl -o:test13.html

xmllint --noout --dtdvalid xhtml1-transitional.dtd *.html
