# Getting started with Git and GitHub

This page contains everything you need to know for getting started with GitHub.


## Installing Git

TODO


## Making a repo on GitHub

A Git repository, or repo for short, is basically a project.
This guide focuses on repos hosted on GitHub,
although most of the instructions will still work even if you don't want to use GitHub.
For example, https://github.com/Akuli/git-guide is the GitHub repo of this guide.
At the time of writing this guide, most open-source projects are developed with a GitHub repo.

The first step is to create the repo on GitHub.
Go to https://github.com/, and click the "New" button next to where it says "Repositories".
Here's what the different settings mean:
- Repository name: Most people prefer all lowercase, with words separated by `-`.
    For example, `git-guide` instead of `Git Guide`.
- Public or private: Usually you should choose public. Making your code publicly available is a good thing.
- Check "Add a README file".
    The purpose of the README file is to briefly explain what the project is
    and what terminal commands should be ran when you get started with developing it.
    All that is important when someone stumbles upon your repo without any prior knowledge about it.
    If you forget to add a README, you can always add it later.
- If your repo is going to contain code written in a specific programming language, check "Add .gitignore",
    and choose the programming language from the list.
    I will explain more about the `.gitignore` file later.
    (TODO: explain it and add link here)
- If you are making a public repository and you don't know what a license is, **please check "Choose a license"**.
    A license is a text file that defines what people can and can't do with the code.
    If you don't know which license to choose from the list,
    have a look at [GitHub's license choosing site](https://choosealicense.com/).

Using a license avoids legal problems that you wouldn't expect to have in the first place:
- Everyone are allowed to use your code (which they should be, since it's public).
- If someone makes a copy of your project, they can't claim that they wrote it by themselves.
- If your code destroys something (even though that's unlikely to happen in practice), nobody can sue you.
    Of course, this doesn't mean that you shouldn't fix problems that your code has;
    it just means that you are not by law required to do anything or pay money to compensate for damage.

For example, I use [the MIT license](https://opensource.org/licenses/MIT) in my projects,
because it's very short but it still guarantees all this.

**I'm not a lawyer**, so I might have gotten some details wrong.
Also, I'm not responsible for anything I say in this guide, as [the LICENCE of this guide](LICENSE) says.


## Cloning the repo

When you have created a repo on GitHub, the first step is to clone it.
It means downloading a copy of the repo to your compter, so that you can edit the files in it.

I will assume you know the basics of using a terminal (or command prompt, if you are using Windows).
In particular, I assume you know how the `cd` command changes the current working directory.
I will also use `dir` (Windows) or `ls` (e.g. Linux and MacOS) to show what's in the current working directory,
but you can instead look at the directory with any file manager program.

Start by `cd`-ing to where you want to clone the repository.
This step is optional, and if you don't do it,
then the repository will be cloned to whatever current working directory the terminal starts in,
such as `C:\Users\username` on Windows, or `/home/username` on Linux, or `/Users/username` on MacOS.
It's just a folder that contains some stuff, so you can move it later.

Then clone the repository like this, replacing `username` and `reponame` with the names of your GitHub account and the repo.
You can also copy/paste the `https://github.com/...` part from the address bar of your web browser.

```sh
$ git clone https://github.com/username/reponame
Cloning into 'reponame'...
remote: Enumerating objects: 6, done.
remote: Total 6 (delta 0), reused 0 (delta 0), pack-reused 6
Unpacking objects: 100% (6/6), done.

$ cd reponame
```

Here `$` means "type the rest of this line to the terminal",
and lines not starting with `$` are output from the commands.

As you can see by the `cd` command, `git clone` created a new folder.
This is where your code will be, although currently only the LICENSE and the README are there:

```sh
$ ls
LICENSE  README.md
```

If you are using Windows, you will need `dir` instead of `ls`,
and the output will be shown slightly differently than above.

In fact, the `.gitignore` is also there, but `ls` doesn't show file names starting with a dot by default.
There's also `.git`, which is a folder where `git` stores files internally.
To see them too, use `ls -a`, where `-a` is short for "all":

```sh
$ ls -a
.  ..  .git  LICENSE  README.md
```

On Windows, `dir` shows everything by default.


## git init

Many other Git instructions recommend `git init` for making a new repo.
Unlike the `git clone https://github.com/...` command above, `git init` does nothing with github;
it creates the repo only on your computer.
Therefore connecting it to GitHub requires more commands to be ran separately.

If you just want to put your code to GitHub, then **don't use `git init`**.
Just make the repo on GitHub first and then clone it.
