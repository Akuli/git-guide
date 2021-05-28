# git-guide

[Click here](https://akuli.github.io/git-guide/) to read this guide.

This is my attempt at writing a practical guide to using Git with GitHub.
Ideally, the official Git documentation would be so good that this isn't necessary, but it sucks.
The goal for this guide is to not suck.


## Developing

You most likely want to edit the files in `mako-templates/`.
When you have changed something, run these commands (on Windows, `py` instead of `python3` and no `source`)

```
$ python3 -m venv env
$ source env/bin/activate
$ pip install -r requirements.txt
$ python3 build.py
```

Now open `html/index.html` with your browser.

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
