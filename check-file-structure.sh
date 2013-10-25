#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error

SCRIPT_DIR=$(dirname $(readlink -f $0))

################################################################################
# CONFIG
################################################################################

# File output to be eaten by probatron
tmpfile="$SCRIPT_DIR/testdata/dump.xml"

# Probatron location
probatrondir="$SCRIPT_DIR/probatron/"

# Output of schemacheck
resultfile="$SCRIPT_DIR/check-result.xml"


schematronFile="$SCRIPT_DIR/schematron/demands.sch"

################################################################################
# CODE
################################################################################

# Validate output against schematron file
cd "$probatrondir"
java -jar probatron.jar "$tmpfile" "$schematronFile" >"$resultfile"

cat "$resultfile"
#perl -E 'say "-" x 80'
echo

