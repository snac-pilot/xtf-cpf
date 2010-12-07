#!/bin/env bash
set -eu
echo "<div class='version'>code -- " > VERSION
changeset=`hg -q id | sed s,\+$,,`
echo "<a href=\"http://bitbucket.org/btingle/cpf2html/changeset/$changeset\">$changeset</a>" >> VERSION
hg parents --template '{date|date}' >> VERSION
echo "<div>data -- " >> VERSION
ls -ald ../data >> VERSION
echo "</div>" >> VERSION
echo "</div>" >> VERSION
