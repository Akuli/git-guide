# git-guide

This is my attempt at writing a practical guide to using Git with GitHub.
Ideally, the official Git documentation would be so good that this isn't necessary, but it sucks.
The goal for this guide is to not suck.

Contents:
- [Getting started](getting-started.md): installing Git, making and cloning a repo
- [Committing](committing.md): add, commit, push, status, diff
- [Branches](branches.md): add, commit, push, status, diff


## Developing

GitHub Actions does the following checks:
- Runs every command starting with `$` in the markdown files,
    and ensures that the markdown file contains the exact output of the command.
    Edit `run_commands.py` if this check fails and you don't want to change the markdown files.
- Spell checks all markdown files.
    If the spell check complains about a word that you know you spelled correctly,
    add the word to `spellcheck_exclude.txt`.

You can also try running these checks on your computer by finding the commands from `.github/workflows/`,
but don't complain to me if that doesn't work;
when working on the checks, I assume they will run only on GitHub Actions.
