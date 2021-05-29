<%inherit file="base.html"/>
<%namespace file="base.html" import="*" />

<p>A <strong>pull request</strong>, or PR for short, is a pile of <a href="committing.html">commits</a>
that whoever created the PR would like to add to a repo.
Usually a pull request fixes a bug, adds a new feature or cleans up the code.
For example, in <a href="https://github.com/kanga333/comment-hider/pull/28">this pull request</a>,
I added a new feature to kanga333's `comment-hider` repo.

<p>In most open-source projects, anyone can create a pull request,
and that's the recommended way to contribute to the project.
For example, kanga333 never gave me any kind of permissions to create a pull request. I just did it.


<%self:h2>Making a pull request</%self:h2>

<p>Usually you don't have the permissions to <a href="branches.html#pushing-a-branch">push a branch</a>
directly to the repository where the pull request will go.
To work around that, the first step is to fork the repository.
It basically means making your own copy of the repository.
For example,
<a href="https://github.com/Akuli/comment-hider">github.com/Akuli/comment-hider</a>
is my fork of
<a href="https://github.com/kanga333/comment-hider">github.com/kanga333/comment-hider</a>.

<p>To create your own fork a repository, open the original repository on GitHub,
and then click the "Fork" button in the top right corner:

<p><img src="images/fork.png" alt='Button that says "Fork", next to "Watch" and "Star" buttons' />

<p>Next you can <a href="getting-started.html#cloning-the-repo">clone</a> your fork.
Make sure you write <strong>your own username</strong> into the command;
otherwise you clone the original repo, even though you don't have permissions to push there.
(TODO: what to do if you already cloned the original repo?)

<%
    import shutil

    # TODO: this is a bit of a hack
    runner = context['parent'].context.runner
    shutil.rmtree(runner.working_dir)
    runner.working_dir = runner.working_dir.parent
%>

<%self:runcommands>
$ git clone https://github.com/username/reponame
Cloning into 'reponame'...
remote: Enumerating objects: 6, done.
remote: Total 6 (delta 0), reused 0 (delta 0), pack-reused 6
Unpacking objects: 100% (6/6), done.
$ cd reponame
</%self:runcommands>

<p>Next make <a href="branches.html">a new branch</a>.
I will name the branch `division`, continuing <a href="branches.html#the-setup">the calculator example</a>.

<%self:runcommands>
$ git checkout -b division
</%self:runcommands>

<p>Let's add a new feature to the calculator, and then <a href="committing.html">commit and push</a> it:

<%self:code lang="python" append="calculator.py">
elif operation == "/":
    print(first_number / second_number)
</%self:code>

<%self:runcommands>
$ git status
$ git add calculator.py
$ git diff --cached
$ git commit -m "new division feature"
$ git push
$ git push --set-upstream origin division
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
remote: Create a pull request for 'division' on GitHub by visiting:
remote:      https://github.com/username/reponame/pull/new/division
remote:
To https://github.com/username/reponame
 * [new branch]      division -> division
Branch 'division' set up to track remote branch 'division' from 'origin'.
</%self:runcommands>

Notice that the `git push` output includes a link.
Open it in your web browser to create the pull request.
You can also go to either repo on GitHub,
and you should see big green "Compare and pull request" buttons.
