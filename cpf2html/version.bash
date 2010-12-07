#!/bin/env bash
set -eu
echo "<div>" > VERSION
hg -q id >> VERSION
hg parents --template '{date|date}' >> VERSION
echo >> VERSION
ls -ald ../data >> VERSION
echo "</div>" >> VERSION
