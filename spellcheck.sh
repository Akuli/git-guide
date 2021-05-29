#!/bin/bash
set -e

# Sometimes commit hashes contain a few consecutive letters, aspell thinks those are words
function delete_commit_hashes()
{
    sed 's/\b[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\b//g'
}

files=$(find mako-templates -name '*.mako' ! -name base.mako)

! grep -nowf <(
    # This subcommand outputs misspelled words in all files, one per line
    cat $files | delete_commit_hashes | aspell -H -l en list | (grep -vxf spellcheck_exclude.txt || true)
) $files
