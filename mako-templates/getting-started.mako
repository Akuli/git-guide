<%inherit file="base.html"/>
<%namespace file="base.html" import="*" />

<p>This page contains everything you need to know for getting started with GitHub.


<h2>Installing Git</h2>

<p>TODO


<h2>Making a repo on GitHub</h2>

<p>A Git repository, or repo for short, is basically a project.
For example, <a href="https://github.com/Akuli/git-guide">github.com/Akuli/git-guide</a> is the GitHub repo of this guide.
This guide focuses on repos that are on GitHub, because at the time of writing this guide,
most open-source projects are developed with a GitHub repo.
However, most of the instructions work even if you don't want to use GitHub.

<p>The first step is to create the repo on GitHub.
Go to <a href="https://github.com/">github.com</a> and click the "New" button next to where it says "Repositories".
Choose the settings like this:

<ul><li>
Repository name: Most people prefer all lowercase, with words separated by `-` or not at all.
For example, `git-guide` or `gitguide` instead of `Git Guide`.
</li><li>
Public or private: Usually you should choose public. Making your code publicly available is a good thing.
</li><li>
Check "Add a README file".
The purpose of the README file is to briefly explain what the project is
and how to get started with developing it.
All that is important when someone stumbles upon your repo without any prior knowledge about it.
If you forget to add a README, you can always add it later.
</li><li>
If your repo is going to contain code written in some programming language, check "Add .gitignore",
and choose the programming language from the list.
I will explain more about the `.gitignore` file later.
(TODO: explain it and add link here)
</li><li>
If you are making a public repository and you don't know what a license is, <strong>please check "Choose a license"</strong>.
A license is a text file that defines what people can and can't do with the code.
If you don't know which license to choose from the list,
have a look at <a href="https://choosealicense.com/">GitHub's license choosing site</a>.
</li></ul>

<p>Using a license avoids surprising legal problems, and instead, everything works as you would expect:

<ul><li>
Everyone can use and modify your code (which really should be allowed, since it's public).
</li><li>
If someone makes a copy of your project, they can't claim that they wrote it by themselves.
</li><li>
If your code destroys something (even though that's unlikely to happen in practice), nobody can sue you.
Of course, this doesn't mean that you shouldn't fix problems that your code has;
it just means that you are not by law required to fix anything or pay money to compensate for damage.
</li></ul>

<p>For example, I use <a href="https://opensource.org/licenses/MIT">the MIT license</a> in my projects,
because it's very short but it still guarantees all this.

<strong>I'm not a lawyer</strong>, so I might have gotten some details wrong.
Also, I'm not responsible for anything I say in this guide,
as <a href="https://github.com/Akuli/git-guide/blob/main/LICENSE">the LICENCE of this guide</a> says.


<h2 id="cloning">Cloning the repo</h2>

<p>After creating a repo on GitHub, the next step is to clone it.
It means downloading a copy of the repo to your computer,
so that you can edit the files in it and then upload your changes to GitHub.

<p>I will assume you know the basics of using a terminal (or command prompt, if you are using Windows).
In particular, I assume you know how the `cd` command changes the current working directory.
I will also use `dir` (Windows) or `ls` (e.g. Linux and MacOS) to show what's in the current working directory,
but you can instead look at the directory with any file manager program.

<p>Start by `cd`-ing to where you want to clone the repository.
This step is optional, and if you don't do it,
then the repository will be cloned to whatever current working directory the terminal starts in,
such as `C:\Users\username` on Windows, or `/home/username` on Linux, or `/Users/username` on MacOS.

<p>Then clone the repository like this, replacing `username` and `reponame` with the names of your GitHub account and the repo.
You can also copy/paste the `https://github.com/...` part from the address bar of your web browser.

<%self:runcommands>
$ git clone https://github.com/username/reponame
Cloning into 'reponame'...
remote: Enumerating objects: 6, done.
remote: Total 6 (delta 0), reused 0 (delta 0), pack-reused 6
Unpacking objects: 100% (6/6), done.
$ cd reponame
</%self:runcommands>

<p>In the above example, lines starting with `$` are the commands that you should type to the terminal,
and other lines are output from those commands.
So `$` means "type the rest of this line to the terminal", and you should get the same output.
The `cd` command doesn't output anything.

<p>As you can see by the `cd` command, `git clone` created a new folder.
I will refer to it as "the cloned repo".
It's just like any other folder; for example,
if you accidentally cloned to the wrong place, just move the folder.
We will later run commands that sync the contents of the cloned repo with GitHub,
and therefore your code should go into the cloned repo folder.

<p>At first, only the LICENSE and the README are in the cloned repo:

<%self:runcommands>
$ ls
</%self:runcommands>

<p>If you are using Windows, you will need `dir` instead of `ls`,
and the output will be shown differently than above.

<p>The `.gitignore` file is also there, but `ls` doesn't show file names starting with a dot by default.
There's also `.git`, which is a folder where git stores its data.
For example, `.git/config` is a file that contains `https://github.com/username/reponame`,
among other things.
To see them too, use `ls -a`, where `-a` is short for "all":

<%self:runcommands>
$ ls -a
</%self:runcommands>

<p>On Windows, `dir` shows everything by default.


<h2>git init</h2>

<p>Many other Git instructions recommend `git init` for making a new repo.
Unlike the `git clone https://github.com/...` command above, `git init` does nothing with GitHub;
it creates the repo only on your computer.
Therefore connecting it to GitHub requires running more commands afterwards.

<p>If you just want to put your code to GitHub, then <strong>don't use `git init`</strong>.
Just make the repo on GitHub first and then clone it.
