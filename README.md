# git-guide

This is my attempt at writing a practical guide to using Git with GitHub.
Ideally, the official Git documentation would be so good that this isn't necessary, but it sucks.
The goal for this guide is to not suck.

Contents:
- [Getting started](getting-started.md): installing Git, making and cloning a repo
- [Committing](committing.md): add, commit, push, status, diff
- [Branches](branches.md): checkout, log, merge


## Developing

```
$ python3 -m venv env
$ source env/bin/activate
$ pip install -r requirements.txt
$ python3 build.py
```

This creates `html` files inside `build/`. Open them with your browser.

If you are using a Linux distro that has `apt`, you can use `loop.sh` to
automatically run `build.py` when something changes,
although you will still need to refresh in the browser:

```
$ sudo apt install inotify-tools
$ ./loop.sh
```

GitHub Actions spell checks all markdown files when you make a pull request.
If the spell check complains about a word that you know you spelled correctly,
add the word to `spellcheck_exclude.txt`.
