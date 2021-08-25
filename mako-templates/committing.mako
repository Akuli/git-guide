<%inherit file="base.html"/>
<%namespace file="base.html" import="*" />

<p>A commit is a pile of changes. For example,
<a href="https://github.com/Akuli/git-guide/commit/07ee936f719060550b2033ac6501b31d52b8f627">this commit</a>
changed two files in this guide:
it deleted (red) and added (green) several things in `getting-started.md`,
and added one line to `run_commands.py`.

<p>Before doing anything else, let's run `git status` just to see what's going on.
It doesn't show much yet, but its output will change as we make a commit.

<%self:runcommands>
$ git status
</%self:runcommands>

<p>If you get an error saying `fatal: not a git repository`,
you forgot to `cd` to the cloned repo as shown <a href="getting-started.html#cloning-the-repo">here</a>.

<p>We'll talk more about branches later, but the last line is relevant;
it basically means you haven't done anything yet.

<p>Now open `README.md` in your favorite text editor and write some text to it.

<%self:code lang="markdown" write="README.md">
# reponame
This is a better description of this repository. Imagine you just wrote it
into your text editor.

More text here. Lorem ipsum blah blah blah.
</%self:code>

<p>Remember to save it in the editor. Then run `git status` again:

<%self:runcommands>
$ git status
</%self:runcommands>

<p>Adding, also known as staging, means choosing what will be included in the next commit.
This way it's possible to edit several files and commit only some of the changes.
Adding a file doesn't modify it;
it just makes Git remember the changes you did.

<p>As the status message suggests, we will use `git add <file>...`.
Here `<file>` means that you should put a file name there,
and `...` means that you can specify several files if you want.
We will add only one file, the README.md:

<%self:runcommands>
$ git add README.md
$ git status
</%self:runcommands>

<p>Notice that now `modified: README.md` shows up under `Changes to be committed`
instead of the previous `Changes not staged for commit`.
It also turned green, and in general, green output of `git status` means "this will be committed".

<p>Before committing, let's look at what is going to be committed.
According to `git status`, something changed in `README.md`, but let's see what exactly changed:

<%self:runcommands>
$ git diff --staged
</%self:runcommands>

<p>The first line of the README is `# reponame`, and it was not changed.
There was one line after that, `The description ...`, and it was deleted.
The rest was added when editing the file in the editor.

<p>Diffing is optional, and it does not affect the output of `git status`,
but it may help you discover problems.
If you notice that something isn't quite right, you can still edit the files,
and then run `git add` again when you are done.
Alternatively, if you don't want to commit any changes to `README.md`,
you can use `git restore` as shown in `git status` output to undo the `git add`:

<%self:runcommands>
$ git status
$ git restore --staged README.md
$ git status
$ git add README.md
$ git status
</%self:runcommands>

<p>Without `--staged`, `git restore` undoes changes that you saved in the editor but didn't `git add` yet.
This is useful when you realize that you wrote something stupid and you want to start over.
The same goes for `git diff`: without `--staged`,
instead of showing what will be included in the commit, it shows changes that aren't added yet.

<p>When you have added the changes you want and checked with `git diff --staged`,
you are ready to `git commit`, like this:

<%self:runcommands>
$ git commit -m "add better description to README"
</%self:runcommands>

<p>This error happens when you try to commit for the first time.
To fix this, run the commands that the error message suggests,
replacing `Your Name` with your GitHub username
and `you@example.com` with the email address you used when creating your GitHub account.

<%self:runcommands>
$ git config --global user.email "you@example.com"
$ git config --global user.name "yourusername"
</%self:runcommands>

<p>Now committing should work:

<%self:runcommands>
$ git commit -m "add better description to README"
</%self:runcommands>

<p>The text after `-m` is a <strong>commit message</strong>.
Enter something descriptive, such as "add better description to README" in this case;
finding something from a long list of commits really sucks if the message of every commit is "files edited".

<p>Now the file no longer shows up as modified in `git status`, because we committed the change:

<%self:runcommands>
$ git status
</%self:runcommands>

<p>You can ignore the `main` part of `origin/main` for now,
but when using Git with GitHub, "origin" means the repo on GitHub.
So, the `git status` output is saying that there is one commit
that you haven't uploaded to GitHub yet.

<p>At this point you can create more commits if you want,
but the commits are only on your computer.
Run `git push` to upload the commits to GitHub:

<%self:runcommands>
$ git push
Username for 'https://github.com': username
Password for 'https://username@github.com':
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 184 bytes | 184.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/username/reponame
   ${commit("HEAD^")}..${commit("HEAD")}  main -> main
</%self:runcommands>

<p>Git will ask for your GitHub username and password.
You won't see the password as you type it in, and that's completely normal.
After pushing, you should immediately your changes on GitHub.


<%self:h2>Looking at previous commits</%self:h2>

<p>Run `git log` to get a list of all previous commits.

<%self:runcommands>
$ git log
</%self:runcommands>

<p>Here `Initial commit` is what GitHub creates when you make a new repo,
and `add better description to README` is the commit we just created.

<p>As you can see, the latest commit is on top, and older commits are below it.
If you have many commits, specify `--oneline` so you can fit more commits on the screen at once:

<%self:runcommands>
$ git log --oneline
</%self:runcommands>

<p>Each commit has a unique <strong>commit hash</strong>, sometimes also known as commit ID or SHA.
For example, the hash of our latest commit is `${commit("HEAD", long=True)}`.
The hashes are often abbreviated by taking a few characters from the beginning,
so `${commit("HEAD")}` and `${commit("HEAD", long=True)}` refer to the same commit.

<p>Use `git show` to show the code changes of a commit:

<%self:runcommands>
$ git show ${commit("HEAD")}
</%self:runcommands>

<p>If you don't specify a commit hash, it shows the latest commit:

<%self:runcommands>
$ git show
</%self:runcommands>


<%self:h2>Commands in older versions of git</%self:h2>

<p>If you find that the `git status` output suggests different commands than in this tutorial,
it's likely because you have an old version of git.
You don't need to update it; just use the commands that your `git status` output suggests
instead of the corresponding commands shown in this tutorial.

<p>For example, if I `git add` a file on my computer and then run `git status`,
it suggests this instead of `git restore --staged`:

<pre>  (use "git rm --cached <file>..." to unstage)</pre>

<p>So on new versions of git, `git restore --staged` and `git rm --cached` do the same thing,
and on my older version of git, only `git rm --cached` works.
There's also a third way to do this, suggested by even older versions of git.

<p>In short, the commands that `git status` suggests will always work,
but the output may depend on the git version.
