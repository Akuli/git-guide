#!/bin/bash
set -e

rm -f misspelled.txt

# Sometimes commit hashes contain a few consecutive letters, aspell thinks those are words
function delete_commit_hashes()
{
    sed 's/\b[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\b//g'
}

for file in *.md; do
    cat $file \
        | delete_commit_hashes \
        | aspell -l en list \
        | (grep -v -f spellcheck_exclude.txt || true) \
        | sed "s/^/$file/g" \
        >> misspelled.txt
done

cat misspelled.txt | sort | uniq
! [ -s misspelled.txt ]
