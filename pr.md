# Pull requests

This page is really WIP


## Making a pull request to someone else's repo

First navigate into the other person's repo. This is ideally done by clicking on his/her profile picture or name. This should show all the repos).
On top right corner of the screen is a Fork button, which copies the given repo to your account.
Finally in order to actually start working on the code it's time to download it on your computer by creating cloned repo.
Keep in mind that the repo, you are cloning needs to be your copy of the repo (one created by Fork button) and not the original one.
Thus the command for cloning should look like this: 
```
$ git clone https://github.com/YOURusername/reponame
```

Once this is done, you can finally start editing the code. Make all the changes you need, and when you're done with it (with preferably the final code working),
it's time to send it back to the github - to your forked copy of the repo. This is done in three steps. First step is to add the file you've just edited. If you are
unsure which file it was, simply navigate to your cloned repo folder in git cmd command line (cd *repofolder*) and use command 'git status', which will return all
the info about recently changed files. Then use 'git add *edited file* command and finally git commit command. This will bring up a dialog screen, in which you're asked
to detail the commited changes you just made. Try to write a short concise description; this will be useful in the future when browsing through lots of them. 
Finally use 'git push' command to 'push' your edited file to the repo. 
