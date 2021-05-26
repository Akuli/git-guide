# Committing

A commit is a pile of changes. For example
[this commit](https://github.com/Akuli/git-guide/commit/07ee936f719060550b2033ac6501b31d52b8f627)
changed two files in this guide:
it deleted (red) and added (green) several things in `getting-started.md`,
and added one line to `run_commands.py`.

Before doing anything else, let's run `git status` just to see what's going on.
It doesn't show much yet, but its output will change as we make a commit.

```diff
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

If you get an error saying `fatal: not a git repository`,
you forgot to `cd` to the cloned repo as shown [here](getting-started.md#cloning-the-repo).

We'll talk more about branches later, but the last line is relevant;
it basically means you haven't done anything yet.

Now open `README.md` in your favorite text editor and add some text to it.
Remember to save it in the editor.
Then run `git status` again:

```diff
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

Adding, also known as staging, means choosing what will be included in the next commit.
This way it's possible to edit several files and commit only some of the changes.
Adding a file doesn't modify it;
it just makes Git remember the changes you did.

As the status message suggests, we will use `git add <file>...`.
Here `<file>` means that you should put a file name there,
and `...` means that you can specify several files if you want.
We will add only one file, the README.md:

```diff
$ git add README.md

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md

```

Notice that now `modified: README.md` shows up under `Changes to be committed`
instead of the previous `Changes not staged for commit`.
It is also green, and previously it was red,
but unfortunately there isn't a good way to display colored command output on GitHub.

Before committing, let's look at what is going to be committed.
According to `git status`, something changed in `README.md`, but let's see what exactly changed:

```diff
$ git diff --staged
diff --git a/README.md b/README.md
index e008dfa..c31289b 100644
--- a/README.md
+++ b/README.md
@@ -1,2 +1,5 @@
 # reponame
-The description of the repository is here by default
+This is a better description of this repository. Imagine you just wrote it
+into your text editor.
+
+More text here. Lorem ipsum blah blah blah.
```

The first line of the README is `# reponame`, and it was not changed.
There was one line after that, `The description ...`, and it was deleted.
The rest was added when editing the file in the editor.

Diffing is optional, and it does not affect the output of `git status`,
but it may help you discover problems.
If you notice that something isn't quite right, you can still edit the files,
and then run `git add` again when you are done.
Alternatively, if you don't want to commit any changes to `README.md`,
you can use `git restore` as shown in `git status` output to undo the `git add`:

```diff
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md


$ git restore --staged README.md

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md

$ git add README.md

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md

```

Without `--staged`, `git restore` undoes changes that you saved in the editor but didn't `git add` yet.
This is useful when you realize that you wrote something stupid and you want to start over.
The same goes for `git diff`: without `--staged`,
instead of showing what will be included in the commit, it shows changes that aren't added yet.

When you have added the changes you want and checked with `git diff --staged`, you are ready to `git commit`, like this:

```diff
$ git commit -m "add better description to README"
Author identity unknown

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: empty ident name (for <>) not allowed
```

This error happens when you try to commit for the first time.
To fix this, run the commands that the error message suggests,
replacing `Your Name` with your GitHub username
and `you@example.com` with the email address you used when creating your GitHub account.

```diff
$ git config --global user.email "you@example.com"

$ git config --global user.name "yourusername"
```

Now committing should work:

```diff
$ git commit -m "add better description to README"
[main 5bf1f4e] add better description to README
 1 file changed, 4 insertions(+), 1 deletion(-)
```

The text after `-m` is a **commit message**.
Enter something descriptive, such as "add better description to README" in this case;
finding something from a long list of commits really sucks if the message of every commit is "files edited".

Now the file no longer shows up as modified in `git status`, because we committed the change:

```diff
$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```

You can ignore the `main` part of `origin/main` for now,
but when using Git with GitHub, "origin" means the repo on GitHub.
So, the `git status` output is saying that there is one commit
that you haven't uploaded to GitHub yet.

At this point you can create more commits if you want,
but the commits are only on your computer.
Run `git push` to upload the commits to GitHub:

```diff
$ git push
Username for 'https://github.com': username
Password for 'https://username@github.com':
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 184 bytes | 184.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/username/reponame
   1f95680..5bf1f4e  main -> main
```

Git will ask for your GitHub username and password.
You won't see the password as you type it in, and that's completely normal.
After pushing, you should immediately your changes on GitHub.


## Looking at previous commits

Run `git log` to get a list of all previous commits.

```diff
$ git log
commit 5bf1f4e2101b044e4032b23fe6940f3cd1c9f33f (HEAD -> main, origin/main, origin/HEAD)
Author: yourusername <you@example.com>
Date: Sun May 23 15:31:25 2021 +0300

    add better description to README

commit 1f956800248ad1d577039a92f05beee9e05c1a0f
Author: yourusername <you@example.com>
Date: Sun May 23 15:34:50 2021 +0300

    Initial commit
```

As you can see, the latest commit is on top, and older commits are below it.
If you have many commits, specify `--oneline` so you can fit more commits on the screen at once:

```diff
$ git log --oneline
5bf1f4e (HEAD -> main, origin/main, origin/HEAD) add better description to README
1f95680 Initial commit
```

Here `Initial commit` is what GitHub creates when you make a new repo,
and `add better description to README` is the commit we just created.

Each commit has a unique **commit hash**, sometimes also known as commit ID or SHA.
For example, the hash of our latest commit is `5bf1f4e2101b044e4032b23fe6940f3cd1c9f33f`.
The hashes are often abbreviated by taking a few characters from the beginning,
so `5bf1f4e` and `5bf1f4e2101b044e4032b23fe6940f3cd1c9f33f` refer to the same commit.

Use `git show` to show the code changes of a commit:

```diff
$ git show 5bf1f4e
commit 5bf1f4e2101b044e4032b23fe6940f3cd1c9f33f (HEAD -> main, origin/main, origin/HEAD)
Author: yourusername <you@example.com>
Date: Sun May 23 15:31:25 2021 +0300

    add better description to README

diff --git a/README.md b/README.md
index e008dfa..c31289b 100644
--- a/README.md
+++ b/README.md
@@ -1,2 +1,5 @@
 # reponame
-The description of the repository is here by default
+This is a better description of this repository. Imagine you just wrote it
+into your text editor.
+
+More text here. Lorem ipsum blah blah blah.
```


## Commands in older versions of git

If you find that the `git status` output suggests different commands than in this tutorial,
it's likely because you have an old version of git.
You don't need to update it; just use the commands that your `git status` output suggests
instead of the corresponding commands shown in this tutorial.

For example, if I `git add` a file on my computer and then run `git status`,
it suggests this instead of `git restore --staged`:

```
  (use "git rm --cached <file>..." to unstage)
```

So on new versions of git, `git restore --staged` and `git rm --cached` do the same thing,
and on my older version of git, only `git rm --cached` works.
There's also a third way to do this, suggested by even older versions of git.

In short, the commands that `git status` suggests will always work,
but the output may depend on the git version.
