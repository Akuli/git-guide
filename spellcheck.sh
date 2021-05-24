#!/bin/bash
set -e

# Sometimes commit hashes contain a few consecutive letters, aspell thinks those are words
function delete_commit_hashes()
{
    sed 's/\b[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\b//g'
}

! grep -nowf <(
    # This subcommand outputs misspelled words in all files, one per line
    cat *.md | delete_commit_hashes | aspell -l en list | (grep -vxf spellcheck_exclude.txt || true)
) *.md
