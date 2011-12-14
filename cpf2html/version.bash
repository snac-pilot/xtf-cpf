#!/bin/env bash
set -eu
echo "<div class='version'>" > VERSION
changeset=`hg -q id | sed s,\+$,,`
echo "<a href=\"http://code.google.com/p/xtf-cpf/source/detail?r=$changeset\">$changeset</a>" >> VERSION
hg parents --template '{date|date}' >> VERSION
echo "—code<div>" >> VERSION
ls -ald ../data >> VERSION
echo "</div>" >> VERSION
echo "<div>" >> VERSION
ls -ald ../index >> VERSION
echo "</div>" >> VERSION
echo "</div>" >> VERSION
