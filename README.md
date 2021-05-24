# git-guide

This is my attempt at writing a practical guide to using Git with GitHub.
Ideally, the official Git documentation would be so good that this isn't necessary, but it sucks.
The goal for this guide is to not suck.

Contents:
- [Getting started](getting-started.md): installing Git, making and cloning a repo
- [Committing](committing.md): add, commit, push, status, diff


## Developing

Run `python3 run_commands.py` after editing the commands in a `.md` file.
It will run the commands you wrote and put the output back to the markdown files.
This way, the commands in markdown files look as if they were written to a terminal.
If you are like me, you are using an older Git version than GitHub Actions,
and the output differs from what CI expect it to be;
in this case, you should make the output match what GitHub Actions wants.

Spell checking:

    sudo apt install aspell
    ./spellcheck.sh
