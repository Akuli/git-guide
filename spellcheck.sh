#!/bin/bash
set -e

rm -f misspelled.txt

for file in *.md; do
    cat $file \
        | sed 's/\b[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\b//g' \
        | aspell -l en list \
        | tee -a wat \
        | (grep -v -f spellcheck_exclude.txt || true) \
        >> misspelled.txt
done

cat misspelled.txt | sort | uniq
! [ -s misspelled.txt ]
