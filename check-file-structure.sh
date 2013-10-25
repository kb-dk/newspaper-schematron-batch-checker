#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error

################################################################################
# CONFIG
################################################################################

# File output to be eaten by probatron
tmpfile='/home/jrg/projects/quick-file-structure-checker/dump.xml'

# Probatron location
probatrondir='/home/jrg/projects/quick-file-structure-checker/probatron/'

# Output of schemacheck
resultfile='/home/jrg/projects/quick-file-structure-checker/check-result.xml'


################################################################################
# CODE
################################################################################

# Validate output against schematron file
cd "$probatrondir"
java -jar probatron.jar "$tmpfile" demands.sch >"$resultfile"

cat "$resultfile"
perl -E 'say "-" x 80'
echo

