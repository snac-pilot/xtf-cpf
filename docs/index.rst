.. xtf-cpf documentation master file, created by
   sphinx-quickstart on Tue May  3 00:49:02 2011.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to xtf-cpf's documentation!
===================================

This is the documentation for the Social Networks and Archival 
Context Projects branch of XTF.  It is designed to work with 
EAC-CPF records.  For more information on SNAC see the project
site at:

   http://socialarchive.iath.virginia.edu/

The most recent and definitive version of the XTF documentation is
available on the XTF site at:

    http://xtf.cdlib.org

The code for this branch is on google code 

   https://xtf-cpf.googlecode.com/

To check out the source code for the SNAC XTF branch 

    hg clone https://xtf-cpf.googlecode.com/hg#xtf-cpf xtf-cpf

set XTF_HOME environmental variable to the xtf-cpf directory

build XTF with ant

    cd WEB-INF
    ant

put EAC files in data directory 

    textIndexer -index default

Configure tomcat; install XTF in tomcat.

hg clone https://eac-graph-load.googlecode.com/hg/ eac-graph-load

The main XSLT can be used directly with saxon to tranform EAC-CPF to HTML

    http://code.google.com/p/xtf-cpf/source/browse/cpf2html/cpf2html.xsl?r=xtf-cpf

cd cpf2html/; ./version.bash creates VERSION file for includes on prototype

Contents:

.. toctree::
   :maxdepth: 2

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

