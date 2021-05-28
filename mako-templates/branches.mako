<%inherit file="base.html"/>
<%namespace file="base.html" import="*" />

<p>Suppose you are working on a calculator program.
You start working on a new multiplication feature,
and you have already <a href="committing.html">committed and pushed</a> several times.
The code is still WIP (Work In Progress, far from done);
it errors when you try to run it, for example.
Then someone discovers a bug, and you want to fix it right away.
But now you have a problem: you can't work on the bug
because you are in the middle of working on multiplication and the code is still WIP.

<p>To prevent this situation, you can make a new <strong>branch</strong> when you start working on multiplication,
and then put all your commits to the new multiplication branch.
Commits on the new branch don't affect the rest of your project,
and you can start fixing the bug at any time.

<p>Next we go through this process in practice.


<h2>The setup</h2>

<p>We will work on the following code.

<%self:code lang="python" write="calculator.py">
import sys

first_number = int(sys.argv[1])
operation = sys.argv[2]
second_number = int(sys.argv[3])

if operation == "+":
    print(first_number + second_number)
elif operation == "-":
    print(first_number + second_number)
</%self:code>

<p>In case you are not familiar with Python code, this program is meant to be called from command line,
and it uses 3 command line arguments to do a calculation.
Like this, for example (use `py` instead of `python3` on Windows):

<%self:runcommands>
$ python3 calculator.py 1 + 2
$ python3 calculator.py 7 - 3
</%self:runcommands>

<p>The subtraction doesn't work; this is the bug that we will fix later.
Let's <a href="committing.html">commit</a> the code:

<%self:runcommands>
$ git status
$ git add calculator.py
$ git status
$ git commit -m "create calculator.py"
$ git status
</%self:runcommands>


<h2>Branch basics</h2>

<p>When I work with branches, I constantly use the following command to check what's going on,
similarly to `git status`:

<%self:runcommands>
$ git log --oneline --graph --all
</%self:runcommands>

<p>We already saw `--oneline` <a href="committing.html#looking-at-previous-commits">last time</a>.
I will explain `--graph` and `--all` soon.

<p>By default, there is only one branch. In new GitHub repos, it's called `main`.
GitHub's name for the default branch used to be `master`,
and many projects still have a branch named `master` instead of a `main` branch.

<p>Seeing `main` next to `${commit("main")}` means that
`${commit("main")}` is the latest commit on `main`.
Here `origin` means GitHub and `origin/main` is GitHub's main branch,
so `${commit("origin/main")}` next to it means that the latest commit we pushed is `${commit("origin/main")}`.

<p>There is also a notion of <strong>current branch</strong>, which is often called `HEAD`.
Above we see `(HEAD -> main)`, which means that now the current branch is `main`.

<p>Let's make a new branch:

<%self:runcommands>
$ git checkout -b multiplication
$ git status
$ git log --oneline --graph --all
</%self:runcommands>

<p>Here `multiplication` is a branch name; you can name a branch however you want.
The latest commit on the `multiplication` branch is `${commit("multiplication")}`, same as on `main`.

<p>We can go back to the `main` branch with `git checkout`, but without `-b`;
the `-b` means that a new branch is created.

<%self:runcommands>
$ git checkout main
$ git status
$ git log --oneline --graph --all
$ git checkout multiplication
$ git status
$ git log --oneline --graph --all
</%self:runcommands>

<p>On the `multiplication` branch, let's create the multiplication code:

<%self:code lang="python" append="calculator.py">
elif operation == "*":
    print(first_number * second_unmber)
</%self:code>

<p>The new multiplication code is buggy, but let's try it and commit it anyway.
We need to quote `*` because it is a special character on the terminal;
it is good to know how that works, but I won't explain it here because I want to focus on git.

<%self:runcommands>
$ python3 calculator.py 2 "*" 3
$ git add calculator.py
$ git diff --cached
$ git commit -m "multiplication code, not working yet"
$ git log --oneline --graph --all
</%self:runcommands>

<p>Note how the `main` branch was left behind when we committed;
our latest commit is only on the `multiplication` branch, because we did `git checkout multiplication` before committing.

<p>Let's leave the multiplication branch for now...

<%self:runcommands>
$ git checkout main
</%self:runcommands>

<p>...and fix the subtraction bug by changing just the last line:

<%self:code lang="python" replacelastline="calculator.py">
    print(first_number - second_number)
</%self:code>

<p>Let's commit the fix:

<%self:runcommands>
$ git add calculator.py
$ git diff --cached
$ git commit -m "fix subtraction bug"
$ git status
$ git log --oneline --graph --all
</%self:runcommands>

<p>Now you can see what the `--graph` does: it shows how commits are based on other commits,
drawing a Y-shaped graph at left in this case.

<p>Without `--all`, git hides some branches.
For example, if you are on `main`, you won't see the `multiplication` branch:

<%self:runcommands>
$ git status
$ git log --oneline --graph
</%self:runcommands>

<p>I guess this might be useful if you have many unrelated branches and you want to ignore them,
but I always use `--all`.


<h2>Think about "is based on" instead of "is newer than"</h2>

<p>Let's go back to the multiplication branch.
<%self:runcommands>
$ git checkout multiplication
$ git log --oneline --graph --all
</%self:runcommands>

<p>Now let's fix the multiplication bug by changing the last line:

<%self:code lang="python" replacelastline="calculator.py">
    print(first_number * second_number)
</%self:code>

<p>Let's try it out and then commit the result:

<%self:runcommands>
$ python3 calculator.py 2 "*" 3
$ git add calculator.py
$ git diff --cached
$ git commit -m "fix multiplication bug"
$ git log --oneline --graph --all
</%self:runcommands>

<p>Now the subtraction fix `${commit("main")}` shows up
below the first multiplication commit `${commit("multiplication^")}`,
even though the multiplication commit is older.
In other words, the latest commit is not always first in the output of our `--graph` command.

<p>If you really want to, you can ask git to sort by commit time by adding `--date-order`:

<%self:runcommands>
$ git log --oneline --graph --all --date-order
</%self:runcommands>

<p>As you can see, it just looks messier this way, which is probably why this is not the default.
I don't use `--date-order` because I don't actually care about
which of two commits on different branches is newer and which is older;
I just want to see what commits each branch contains,
and how `${commit("main")}` and `${commit("multiplication^")}`
are both based on `${commit("main^")}`, for example.


<h2>Pushing a branch</h2>

<p>Run `git push` to upload the current branch to GitHub.
For example, we are currently on the `multiplication` branch,
so `git push` will push that branch to GitHub.

<%self:runcommands>
$ git status
$ git push
</%self:runcommands>

<p>This error message is confusing,
but just copy/paste the command it suggests and run it.

<%self:runcommands>
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
</%self:runcommands>

<p>Now Git will remember that you already ran the command it suggested,
and `git push` without anything else after it will work next time.
This is branch-specific though, so you need to do the `--set-upstream` thing once for each branch.

<p>In GitHub, there should be a menu where you can choose a branch and it says `main` by default.
You should now see a `multiplication` branch in that menu,
and if you click it and then open `calculator.py`, you should see the multiplication code.

<p>The `git push` output contains a link for creating a pull request. We will use it later.
(TODO: write about pull requests)


<h2>Merges and merge conflicts</h2>

<p>Now we have two versions of the calculator program:
the code on `main` can subtract correctly, and the code on `multiplication` can multiply.

<%self:runcommands>
$ git log --oneline --graph --all
</%self:runcommands>

<p>Next we want to combine the changes from the `multiplication` branch into the `main` branch
so that on `main`, subtraction and multiplication both work, and we no longer need the `multiplication` branch.
This is called <strong>merging</strong> the multiplication branch into `main`.

<p>Before merging, you need to go to the branch where you want the result to be:

<%self:runcommands>
$ git checkout main
</%self:runcommands>

<p>Now we can merge.

<%self:runcommands>
$ git merge multiplication
$ git status
</%self:runcommands>

<p>Git tried to combine the changes (`Auto-merging calculator.py`),
but it couldn't do it (`Automatic merge failed`)
because the two branches contain conflicting changes (`CONFLICT`).
In these cases, git needs your help.

<p>Open `calculator.py` in your editor. You should see this:

<%self:code lang="python" read="calculator.py" />

<p>The code on main (current branch, aka `HEAD`) is between `<<<<<<<` and `=======`.
That's the correct subtraction code.
The code on `multiplication` branch is between `=======` and `>>>>>>>`.
Now you have to combine it all together:
you need to include the `*` code and make sure that the subtraction code actually subtracts.
Like this:

<%self:code lang="python" write="calculator.py">
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
</%self:code>

<p>Let's check whether we combined it correctly:

<%self:runcommands>
$ python3 calculator.py 7 - 3
$ python3 calculator.py 2 "*" 3
</%self:runcommands>

<p>Let's ask `git status` what we should do next:

<%self:runcommands>
$ git status
</%self:runcommands>

<p>The relevant part is `(use "git add <file>..." to mark resolution)`,
which means that once the conflicts are fixed, we should `git add` the file.
Let's do that:

<%self:runcommands>
$ git add calculator.py
$ git status
</%self:runcommands>

As `git status` says, the next step is to commit the result.
<strong>Do not use `-m` with merge commits</strong> such as this one.
Instead, write just `git commit`, without anything else after it.
It will open an editor that already contains a commit message for you;
just close the editor by pressing Ctrl+X and you are done.

<%self:runcommands>
$ git commit
$ git log --oneline --graph --all
</%self:runcommands>

<p>The default commit message, `Merge branch 'multiplication'`, is very recognizable:
when people see it in git logs, they immediately know what that commit does.


<h2>Deleting a branch</h2>

<p>Because we have now merged `multiplication` into `main`,
we no longer need the `multiplication` branch and we can delete it.

<p>Let's start with `git branch -D`:

<%self:runcommands>
$ git log --oneline --graph --all
$ git branch -D multiplication
$ git log --oneline --graph --all
</%self:runcommands>

<p>We can see that `origin/multiplication` wasn't deleted, so the branch is still on GitHub.
Let's delete it from GitHub too:

<%self:runcommands>
$ git push --delete origin multiplication
To https://github.com/username/reponame
 - [deleted]         multiplication
$ git log --oneline --graph --all
</%self:runcommands>

<p>For whatever reason, you need to specify `origin` in the `git push` command.
As usual, `origin` means GitHub.
