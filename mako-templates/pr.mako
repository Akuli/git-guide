<%inherit file="base.html"/>
<%namespace file="base.html" import="*" />

<p>A <strong>pull request</strong>, or PR for short, is a bunch of <a href="committing.html">commits</a>
that the person who created the PR would like to add to a repo.
Usually a PR fixes a bug, adds a new feature or cleans up the code.
For example, in <a href="https://github.com/kanga333/comment-hider/pull/28">this PR</a>,
I added a new feature to kanga333's `comment-hider` repo.

<p>In most open-source projects, anyone can create a PR,
and that's the recommended way to contribute to the project.
For example, kanga333 never gave me any kind of permissions to create a PR. I just did it.


<%self:h2>Making a PR</%self:h2>

<p>Usually you don't have the permissions to <a href="branches.html#pushing-a-branch">push a branch</a>
directly to the repo where the PR will go.
To work around that, the first step is to fork the repo.
It basically means making your own copy of the repo.
For example,
<a href="https://github.com/Akuli/comment-hider">github.com/Akuli/comment-hider</a>
is my fork of
<a href="https://github.com/kanga333/comment-hider">github.com/kanga333/comment-hider</a>.

<p>To create your own fork repo, open the original repo on GitHub,
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
$ git lola
</%self:runcommands>

<p>We will continue from <a href="branches.html#the-setup">this calculator example</a>.

<%# self:code lang="python" read="calculator.py" />
%>
<p>Next make <a href="branches.html">a new branch</a>. I will name it `division`.

<%self:runcommands>
$ git checkout -b division
</%self:runcommands>

<p>Let's add a new feature to the calculator, and then <a href="committing.html">commit and push</a> it:

<%self:code lang="python" append="calculator.py">
elif operation == '/':
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

<p>Notice that the `git push` output includes a link.
Open it in your web browser.
Alternatively, you can go to either repo on GitHub,
and you should see big green "Compare &amp; pull request" buttons:

<p><img src="images/pr-button.png" alt='Big green button says "Compare & pull request"' />

<p>Adjust the title and description of the PR as needed.
Try to write the title so that it's easy to see what the PR does
when it shows up in the same list with many other PRs.

<p><img src="images/creating-pr.png" alt='Title "support division" and example command to divide' />

<p>Then click "Create pull request" and wait for someone to review the PR.


<%self:h2>Creating a review</%self:h2>

<p>When your repo receives a PR, you shouldn't accept it blindly.
Usually the PR needs more work, and you should leave feedback.
This is called a <strong>code review</strong>, or a <strong>review</strong> for short.

<p>First, go to the "Files changed" tab in the PR:

<p><img src="images/files-changed-tab.png" alt='"Files changed" tab next to "Commits" and "Checks" tabs' />

<p>Read the changes. If there's something wrong with a specific line,
hover the line with your mouse, and a blue `+` icon should appear.

<p><img src="images/review-comment-hover.png" />

<p>Click the blue + icon. This will let you comment the line.

<p>If you want to do a specific change to the line, click the plus-minus button at top left corner.
The line should appear in the comment, and you can edit it to be like you wanted it.
For example, I changed `'` to `"`, and briefly explained why.

<p><img src="images/review-suggestion.png" />

<p>When the comment is done, click "Start a review".
Add more review comments similarly if needed, and then click "Finish your review" at top left.
Fill in the dialog box that appears and then click "Submit review".
Once done, your review should look something like this:

<p><img src="images/review-done.png" />

<p>When the PR finally looks good after enough reviewing and fixing, you can merge the PR;
this merges the branch that the code comes from.


<%self:h2>Responding to a review</%self:h2>

<p>Imagine you are the person who wrote the PR.
When your PR has been reviewed, you need to fix any issues that the reviewer brought up.
If they left a suggestion, just click "Commit suggestion",
and then confirm by clicking the "Commit changes" button that comes up.
If not, <a href="committing.html">commit and push</a> more changes to the branch,
and the changes will automatically appear on GitHub.

<%
    import subprocess

    subprocess.run(['git', 'reset', 'HEAD', '.'], check=True, cwd=runner.fake_github_dir)
    subprocess.run(['git', 'checkout', '.'], check=True, cwd=runner.fake_github_dir)
    subprocess.run(['git', 'checkout', 'division'], check=True, cwd=runner.fake_github_dir)

    # Do what committing suggestion would do
    path = runner.fake_github_dir / 'calculator.py'
    path.write_text(path.read_text().replace("'", '"'))
    subprocess.run(['git', 'add', 'calculator.py'], check=True, cwd=runner.fake_github_dir)
    subprocess.run(['git', 'commit', '-m', 'Update calculator.py'], check=True, cwd=runner.fake_github_dir)

    # Also, create a push error intentionally
    subprocess.run(['git', 'commit', '--allow-empty', '-m', 'commit created on cloned repo'], check=True, cwd=runner.working_dir)
%>

<p>The "Commit suggestion" button creates a commit only on GitHub.
On the other hand, `git commit` creates the commit only on your computer.
To see what happens when these collide, suppose you created a commit on your computer,
with the commit message `commit created on cloned repo`,
and you used the "Commit suggestion" button on GitHub.
When you try to push your commit, it fails:

<%self:runcommands>
$ git push
</%self:runcommands>

<p>In this situation, as the error message suggests, you need to `git pull` before you can `git push`.
As you would expect, this downloads commits from GitHub to the cloned repo on your computer.

<%self:runcommands>
$ git pull
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
From https://github.com/username/reponame
   67a661d..a198d97  division   -> origin/division
Merge made by the 'recursive' strategy.
 calculator.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git lola
</%self:runcommands>

<p>Note that `git pull` created a merge commit;
it merges the commit on your computer (`commit created on cloned repo`)
and the commit created by the "Commit suggestion" button (`Update calculator.py`).
Therefore everything I said about
<a href="branches.html#merges-and-merge-conflicts">merges and merge conflicts</a> applies here too.

<p>As you can see from the `git lola` output, `origin/division` (i.e. the `division` branch on GitHub)
isn't up to date yet, and we need to push:

<%self:runcommands>
$ git push
Enumerating objects: 2, done.
Counting objects: 100% (2/2), done.
Delta compression using up to 2 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 410 bytes | 410.00 KiB/s, done.
Total 2 (delta 0), reused 0 (delta 0)
To https://github.com/username/reponame
   a198d97..a7cf99d  division -> division
$ git lola
</%self:runcommands>


<%self:h2>Merging a PR</%self:h2>

<p>Imagine you are the reviewer.
After enough reviewing, when the PR looks good, click "Merge pull request".
As you would expect, this merges the PR author's branch into your main branch.

<p>Many people prefer "Squash and merge",
which causes the whole pull request to show up as just one commit in `git lola`,
regardless of how many commits the PR author actually created.
You can find that option by clicking the little arrow in the merge button:

<p><img src="images/squash-and-merge.png" />


<%self:h2>Making another PR</%self:h2>

<p>Imagine you are the person who wrote the PR.
While you are waiting for the division PR to get reviewed for the second time, and hopefully merged,
you look at the code and you notice something:
it doesn't handle invalid inputs for the operation.
There's no error, and it just doesn't do anything.

<%self:runcommands>
$ python3 calculator.py 1 + 2
$ python3 calculator.py 1 / 2
$ python3 calculator.py 1 lolwut 2
</%self:runcommands>

You decide to make another PR to fix it.
But before you can run `git checkout -b`, there are a couple gotchas to be aware of:

<ul><li>
    <p>Your new PR should be based on what's on the `main` branch,
    not based on what you have on the `division` branch.
    Otherwise the new PR will also contain the division fixes, which isn't nice for the reviewers;
    they want to review one thing at a time.
    We can fix this with `git checkout main`,
    so that `git checkout -b` will create the new branch based on that.
</li><li>
    <p>Maybe it's been a while since you cloned the repo,
    and since then, the original repo has gotten other commits and PRs.
    To avoid unnecessary merge conflicts,
    your new PR should be based on the latest commit of the original repo.
    We can fix this by pulling from the original repo.
</li></ul>

<p>For this illustration, suppose that the original repo has gotten two new commits unrelated to your PRs,
with commit messages `unrelated commit 1` and `unrelated commit 2`.

<%
    # Create fake fork source dir
    subprocess.run(['git', 'clone', str(runner.fake_github_dir), str(runner.fake_fork_source_dir)], check=True)
    subprocess.run(['git', 'checkout', 'main'], cwd=runner.fake_fork_source_dir, check=True)
    subprocess.run(['git', 'remote', 'rm', 'origin'], cwd=runner.fake_fork_source_dir, check=True)
    subprocess.run(['git', 'branch', '-D', 'division'], cwd=runner.fake_fork_source_dir, check=True)
    subprocess.run(['git', 'commit', '--allow-empty', '-m', 'unrelated commit 1'], cwd=runner.fake_fork_source_dir, check=True)
    subprocess.run(['git', 'commit', '--allow-empty', '-m', 'unrelated commit 2'], cwd=runner.fake_fork_source_dir, check=True)
    unrelated2_hash = subprocess.check_output(
        ['git', 'rev-parse', 'HEAD'],
        cwd=runner.fake_fork_source_dir,
    ).decode('ascii').strip()[:7]
%>

<p>Let's fix the problems:

<%self:runcommands>
$ git lola
$ git checkout main
$ git pull https://github.com/where_you_forked_it_from/reponame
remote: Enumerating objects: 2, done.
remote: Counting objects: 100% (2/2), done.
remote: Total 2 (delta 1), reused 2 (delta 1), pack-reused 0
Unpacking objects: 100% (2/2), done.
From https://github.com/where_you_forked_it_from/reponame
 * branch            HEAD       -> FETCH_HEAD
Updating ${commit("main")}..${unrelated2_hash}
Fast-forward
$ git lola
</%self:runcommands>

<p>With this pull, make sure to specify the <strong>original</strong> repo, not your fork;
if you find yourself writing your GitHub username to that command, you are likely doing it wrong.

<p>You might notice that `origin/main` is left behind, even though the two unrelated commits are on GitHub.
This is because `origin/main` means your fork's main branch, as that is what you cloned.
You can run `git push` on the `main` branch if you want,
but most people don't bother with updating the `main` branches of their forks.

<p>From here on, you can make the PR as described above.


<%self:h2>Conflicting PRs</%self:h2>

As explained above, the original repo can change while your PR isn't merged yet.
If it changes in a way that conflicts with your PR, you will see this in GitHub:

<p><img src="images/github-conflict.png" />

To solve this, pull from the original repo as above, but do it on your PR branch.
You will get <a href="branches.html#merges-and-merge-conflicts">merge conflicts</a>
that you will have to resolve.

For example, if the division PR conflicts, you would do this:

<%self:runcommands>
$ git checkout division
$ git pull https://github.com/where_you_forked_it_from/reponame
remote: Enumerating objects: 2, done.
remote: Counting objects: 100% (2/2), done.
remote: Total 2 (delta 1), reused 2 (delta 1), pack-reused 0
Unpacking objects: 100% (2/2), done.
From https://github.com/where_you_forked_it_from/reponame
 * branch            HEAD       -> FETCH_HEAD
Auto-merging calculator.py
CONFLICT (content): Merge conflict in calculator.py
Automatic merge failed; fix conflicts and then commit the result.
</%self:runcommands>
