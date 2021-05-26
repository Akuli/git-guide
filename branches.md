# Branches

Suppose you are working on a calculator program.
You start working on a new multiplication feature,
and you have already [committed and pushed](committing.md) several times.
The code is still WIP (Work In Progress, far from done);
it errors when you try to run it, for example.
Then someone discovers a bug, and you want to fix it right away.
But now you have a problem: you can't work on the bug
because you are in the middle of working on multiplication and the code is still WIP.

To prevent this situation, you can make a new **branch** when you start working on multiplication,
and then put all your commits to the new multiplication branch.
Commits on the new branch don't affect the rest of your project,
and you can start fixing the bug at any time.

Next we go through this process in practice.


## The setup

Suppose that `calculator.py` contains the following Python program:

```python
# Write this to calculator.py
import sys

first_number = int(sys.argv[1])
operation = sys.argv[2]
second_number = int(sys.argv[3])

if operation == "+":
    print(first_number + second_number)
elif operation == "-":
    print(first_number + second_number)
```

In case you are not familiar with Python code, this program is meant to be called from command line,
and it uses 3 command line arguments to do a calculation.
Like this, for example (use `py` instead of `python3` on Windows):

```diff
$ python3 calculator.py 1 + 2
3

$ python3 calculator.py 7 - 3
10
```

The subtraction doesn't work; this is the bug that we will fix later.
Let's [commit](committing.md) the code:

```diff
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        calculator.py

nothing added to commit but untracked files present (use "git add" to track)

$ git add calculator.py

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   calculator.py


$ git commit -m "create calculator.py"
[main 78b197b] create calculator.py
 1 file changed, 10 insertions(+)
 create mode 100644 calculator.py

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```


## Branch basics

When I work with branches, I constantly use the following command to check what's going on,
similarly to `git status`:

```diff
$ git log --oneline --graph --all
* 78b197b (HEAD -> main) create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

We already saw `--oneline` [last time](committing.md#looking-at-previous-commits).
I will explain `--graph` and `--all` soon.

By default, there is only one branch. In new GitHub repos, it's called `main`.
GitHub's name for the default branch used to be `master`,
and many projects still have a branch named `master` instead of a `main` branch.

Seeing `main` next to `78b197b` means that `78b197b` is the latest commit on `main`.
Here `origin` means GitHub and `origin/main` is GitHub's main branch,
so `5bf1f4e` next to it means that the latest commit we pushed is `5bf1f4e`.

There is also a notion of **current branch**, which is often called `HEAD`.
Above we see `(HEAD -> main)`, which means that now the current branch is `main`.

Let's make a new branch:

```diff
$ git checkout -b multiplication
Switched to a new branch 'multiplication'

$ git status
On branch multiplication
nothing to commit, working tree clean

$ git log --oneline --graph --all
* 78b197b (HEAD -> multiplication, main) create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

Here `multiplication` is a branch name; you can name a branch however you want.
The latest commit on the `multiplication` branch is `78b197b`, same as on `main`.

We can go back to the `main` branch with `git checkout`, but without `-b`;
the `-b` means that a new branch is created.

```diff
$ git checkout main
Switched to branch 'main'
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git log --oneline --graph --all
* 78b197b (HEAD -> main, multiplication) create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit

$ git checkout multiplication
Switched to branch 'multiplication'

$ git status
On branch multiplication
nothing to commit, working tree clean

$ git log --oneline --graph --all
* 78b197b (HEAD -> multiplication, main) create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

On the `multiplication` branch, let's create the multiplication code:

```python
# Add to end of calculator.py (on branch multiplication)
elif operation == "*":
    print(first_number * second_unmber)
```

The new multiplication code is buggy, but let's try it and commit it anyway.
We need to quote `*` because it is a special character on the terminal;
it is good to know how that works, but I won't explain it here because I want to focus on git.

```diff
$ python3 calculator.py 2 "*" 3
Traceback (most recent call last):
  File "calculator.py", line 12, in <module>
    print(first_number * second_unmber)
NameError: name 'second_unmber' is not defined

$ git add calculator.py

$ git diff --cached
diff --git a/calculator.py b/calculator.py
index 94265fe..9900601 100644
--- a/calculator.py
+++ b/calculator.py
@@ -8,3 +8,5 @@ if operation == "+":
     print(first_number + second_number)
 elif operation == "-":
     print(first_number + second_number)
+elif operation == "*":
+    print(first_number * second_unmber)

$ git commit -m "multiplication code, not working yet"
[multiplication 9900601] multiplication code, not working yet
 1 file changed, 2 insertions(+)

$ git log --oneline --graph --all
* 9900601 (HEAD -> multiplication) multiplication code, not working yet
* 78b197b (main) create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

Note how the `main` branch was left behind when we committed;
our latest commit is only on the `multiplication` branch, because we did `git checkout multiplication` before committing.

Let's leave the multiplication branch for now...

```diff
$ git checkout main
Switched to branch 'main'
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)
```

...and fix the subtraction bug by changing just the last line:

```python
# Last line of calculator.py (on branch main)
    print(first_number - second_number)
```

Let's commit the fix:

```diff
$ git add calculator.py

$ git diff --cached
diff --git a/calculator.py b/calculator.py
index 94265fe..4a5095b 100644
--- a/calculator.py
+++ b/calculator.py
@@ -7,4 +7,4 @@ second_number = int(sys.argv[3])
 if operation == "+":
     print(first_number + second_number)
 elif operation == "-":
-    print(first_number + second_number)
+    print(first_number - second_number)

$ git commit -m "fix subtraction bug"
[main a713ead] fix subtraction bug
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git log --oneline --graph --all
* a713ead (HEAD -> main) fix subtraction bug
| * 9900601 (multiplication) multiplication code, not working yet
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

Now you can see what the `--graph` does: it shows how commits are based on other commits,
drawing a Y-shaped graph at left in this case.

Without `--all`, git hides some branches.
For example, if you are on `main`, you won't see the `multiplication` branch:

```diff
$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git log --oneline --graph
* a713ead (HEAD -> main) fix subtraction bug
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

I guess this might be useful if you have many unrelated branches and you want to ignore them,
but I always use `--all`.


## Think about "is based on" instead of "is newer than"

Let's go back to the multiplication branch.
```diff
$ git checkout multiplication
Switched to branch 'multiplication'

$ git log --oneline --graph --all
* a713ead (main) fix subtraction bug
| * 9900601 (HEAD -> multiplication) multiplication code, not working yet
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

Now let's fix the multiplication bug by changing the last line:

```python
# Last line of calculator.py (on branch multiplication)
    print(first_number * second_number)
```

Let's try it out and then commit the result:

```diff
$ python3 calculator.py 2 "*" 3
6

$ git add calculator.py

$ git diff --cached
diff --git a/calculator.py b/calculator.py
index 9900601..8f466b5 100644
--- a/calculator.py
+++ b/calculator.py
@@ -9,4 +9,4 @@ if operation == "+":
 elif operation == "-":
     print(first_number + second_number)
 elif operation == "*":
-    print(first_number * second_unmber)
+    print(first_number * second_number)

$ git commit -m "fix multiplication bug"
[multiplication 6f43004] fix multiplication bug
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git log --oneline --graph --all
* 6f43004 (HEAD -> multiplication) fix multiplication bug
* 9900601 multiplication code, not working yet
| * a713ead (main) fix subtraction bug
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

Now the subtraction fix `a713ead` shows up below the first multiplication commit `9900601`,
even though the multiplication commit is older.
In other words, the latest commit is not always first in the output of our `--graph` command.

If you really want to, you can ask git to sort by commit time by adding `--date-order`:

```diff
$ git log --oneline --graph --all --date-order
* 6f43004 (HEAD -> multiplication) fix multiplication bug
| * a713ead (main) fix subtraction bug
* | 9900601 multiplication code, not working yet
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

As you can see, it just looks messier this way, which is probably why this is not the default.
I don't use `--date-order` because I don't actually care about
which of two commits on different branches is newer and which is older;
I just want to see what commits each branch contains,
and how `9900601` and `a713ead` are both based on `78b197b`, for example.


## Pushing a branch

Run `git push` to upload the current branch to GitHub.
For example, we are currently on the `multiplication` branch,
so `git push` will push that branch to GitHub.

```diff
$ git status
On branch multiplication
nothing to commit, working tree clean

$ git push
fatal: The current branch branches has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin multiplication
```

This error message is confusing,
but you can copy/paste the command it suggests and run that instead.

```diff
$ git push --set-upstream origin multiplication
Username for 'https://github.com': username
Password for 'https://username@github.com':
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 2 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 5.76 KiB | 5.76 MiB/s, done.
Total 8 (delta 5), reused 0 (delta 0)
remote: Resolving deltas: 100% (5/5), completed with 4 local objects.
remote:
remote: Create a pull request for 'multiplication' on GitHub by visiting:
remote:      https://github.com/username/reponame/pull/new/multiplication
remote:
To https://github.com/username/reponame
 * [new branch]      multiplication -> multiplication
Branch 'multiplication' set up to track remote branch 'multiplication' from 'origin'.
```

Now Git will remember that you already ran the command it suggested,
and `git push` without anything else after it will work next time.
This is branch-specific though, so you need to do the `--set-upstream` thing once for each branch.

In GitHub, there should be a menu where you can choose a branch and it says `main` by default.
You should now see a `multiplication` branch in that menu,
and if you click it and then open `calculator.py`, you should see the multiplication code.

The `git push` output contains a link for creating a pull request. We will use it later.
(TODO: write about pull requests)


## Merges and merge conflicts

Now we have two versions of the calculator program:
the code on `main` can subtract correctly, and the code on `multiplication` can multiply.

```diff
$ git log --oneline --graph --all
* 6f43004 (HEAD -> multiplication, origin/multiplication) fix multiplication bug
* 9900601 multiplication code, not working yet
| * a713ead (main) fix subtraction bug
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

Next we want to combine the changes from the `multiplication` branch into the `main` branch
so that on `main`, subtraction and multiplication both work, and we no longer need the `multiplication` branch.
This is called **merging** the multiplication branch into `main`.

Before merging, you need to go to the branch where you want the result to be:

```diff
$ git checkout main
Switched to branch 'main'
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)
```

Now we can merge.

```diff
$ git merge multiplication
Auto-merging calculator.py
CONFLICT (content): Merge conflict in calculator.py
Automatic merge failed; fix conflicts and then commit the result.

$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   calculator.py

no changes added to commit (use "git add" and/or "git commit -a")
```

Git tried to combine the changes (`Auto-merging calculator.py`),
but it couldn't do it (`Automatic merge failed`)
because the two branches contain conflicting changes (`CONFLICT`).
In these cases, git needs your help.

Open `calculator.py` in your editor. You should see this:

[comment]: # (Indented instead of triple backtick to prevent my editor thinking this file has merge conflicts)

    import sys

    first_number = int(sys.argv[1])
    operation = sys.argv[2]
    second_number = int(sys.argv[3])

    if operation == "+":
        print(first_number + second_number)
    elif operation == "-":
    <<<<<<< HEAD
        print(first_number - second_number)
    =======
        print(first_number + second_number)
    elif operation == "*":
        print(first_number * second_number)
    >>>>>>> multiplication

The code on main (current branch, aka `HEAD`) is between `<<<<<<<` and `=======`.
That's the correct subtraction code.
The code on `multiplication` branch is between `=======` and `>>>>>>>`.
Now you have to combine it all together:
you need to include the `*` code and make sure that the subtraction code actually subtracts.
Like this:

```python
# Edit calculator.py so that it looks like this
import sys

first_number = int(sys.argv[1])
operation = sys.argv[2]
second_number = int(sys.argv[3])

if operation == "+":
    print(first_number + second_number)
elif operation == "-":
    print(first_number - second_number)
elif operation == "*":
    print(first_number * second_number)
```

Let's check whether we combined it correctly:

```diff
$ python3 calculator.py 7 - 3
4

$ python3 calculator.py 2 "*" 3
6
```

Let's ask `git status` what we should do next:

```diff
$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   calculator.py

no changes added to commit (use "git add" and/or "git commit -a")
```

The relevant part is `(use "git add <file>..." to mark resolution)`,
which means that once the conflicts are fixed, we should `git add` the file.
Let's do that:

```diff
$ git add calculator.py

$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

Changes to be committed:
        modified:   calculator.py

```

As `git status` says, the next step is to commit the result.
**Do not use `-m` with merge commits** such as this one.
Instead, write just `git commit`, without anything else after it.
It will open an editor that already contains a commit message for you;
just close the editor by pressing Ctrl+X and you are done.

```diff
$ git commit
hint: Waiting for your editor to close the file...
[main c8e61ef] Merge branch 'multiplication'

$ git log --oneline --graph --all
*   c8e61ef (HEAD -> main) Merge branch 'multiplication'
|\  
| * 6f43004 (origin/multiplication, multiplication) fix multiplication bug
| * 9900601 multiplication code, not working yet
* | a713ead fix subtraction bug
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

The default commit message, `Merge branch 'multiplication' into main`, is very recognizable:
when people see it in git logs, they immediately know what that commit does.


## Deleting a branch

Because we have now merged `multiplication` into `main`,
we no longer need the `multiplication` branch and we can delete it.

Let's start with `git branch -D`:

```diff
$ git log --oneline --graph --all
*   c8e61ef (HEAD -> main) Merge branch 'multiplication' into main
|\  
| * 6f43004 (origin/multiplication, multiplication) fix multiplication bug
| * 9900601 multiplication code, not working yet
* | a713ead fix subtraction bug
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit

$ git branch -D multiplication
Deleted branch multiplication (was 6f43004).

$ git log --oneline --graph --all
*   c8e61ef (HEAD -> main) Merge branch 'multiplication' into main
|\  
| * 6f43004 (origin/multiplication) fix multiplication bug
| * 9900601 multiplication code, not working yet
* | a713ead fix subtraction bug
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

We can see that `origin/multiplication` wasn't deleted, so the branch is still on GitHub.
Let's delete it from GitHub too:

```diff
$ git push --delete origin multiplication
To https://github.com/username/reponame
 - [deleted]         multiplication

$ git log --oneline --graph --all
*   c8e61ef (HEAD -> main) Merge branch 'multiplication' into main
|\  
| * 6f43004 fix multiplication bug
| * 9900601 multiplication code, not working yet
* | a713ead fix subtraction bug
|/  
* 78b197b create calculator.py
* 5bf1f4e (origin/main, origin/HEAD) add better description to README
* 1f95680 Initial commit
```

For whatever reason, you need to specify `origin` in the `git push` command.
As usual, `origin` means GitHub.
