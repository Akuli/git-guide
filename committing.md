# Committing

A commit is a pile of changes. For example
[this commit](https://github.com/Akuli/git-guide/commit/07ee936f719060550b2033ac6501b31d52b8f627)
changed two files in this guide:
it deleted (red) and added (green) several things in `getting-started.md`,
and added one line to `run_commands.py`.

Before doing anything else, let's run `git status` just to see what's going on.
It doesn't show much yet, but its output will change as we make a commit.

```sh
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

We'll talk more about branches later, but the last line is relevant;
it basically means you haven't done anything yet.

Now open `README.md` in your favorite text editor and add some text to it.
Remember to save it in the editor.
Then run `git status` again:

```sh
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

```sh
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
index a93665e..610acc2 100644
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

```sh
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

no changes added to commit (use "git add" and/or "git commit -a")

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

When you have added the changes you want and checked with `git diff --staged`, you are ready to `git commit`.
When you commit for the first time, you get an error like this:

```sh
$ git commit
Author identity unknown

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: empty ident name (for <>) not allowed
```

To fix this, run the commands that the error message suggests,
replacing `Your Name` with your GitHub username
and `you@example.com` with the email address you used when creating your GitHub account.

```sh
$ git config --global user.email "you@example.com"

$ git config --global user.name "Your Name"
```

Now committing should work:

```sh
$ git commit
hint: Waiting for your editor to close the file...
[main cb3baec] add better description to README
 1 file changed, 4 insertions(+), 1 deletion(-)
```

When you run `git commit`, it will open an editor where you can enter a **commit message**.
Enter something descriptive, such as "add better description to README" in this case;
finding something from a long list of commits really sucks if the message of every commit is "files edited".
Press Ctrl+X to exit the editor.

Now the file no longer shows up as modified in `git status`, because we committed the change:

```sh
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

```sh
$ git push
Username for 'https://github.com': username
Password for 'https://username@github.com':
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 184 bytes | 184.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/username/reponame
   094eb39..cb3baec  main -> main
```

Git will ask for your GitHub username and password.
You won't see the password as you type it in, and that's completely normal.
After pushing, you should immediately your changes on GitHub.
