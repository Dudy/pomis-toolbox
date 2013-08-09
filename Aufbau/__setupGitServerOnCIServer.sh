#------------------------------------------------------------------------------------------------------------------------------------------------
#When you have a local GIT repo that you want to share with someone else, this is what you have to do.
#Assume your git repo is located in /User/git/myrepo
#
#1. Reinit your git repo to enable sharing (man page)
#
#cd /User/git/myrepo
#git init share=true
#
#2. Add a marker file to the .git directory to tell the daemon that it should be remotely accessible.
#touch /User/git/myrepo/.git/git-daemon-export-ok
#
#3. Start the GIT daemon (man page)
#git daemon --base-path=/User/git
#
#4. Now someone else can add your repository as a remote repository (man page)
#git remote add RepoName git://your.host.name/myrepo
#------------------------------------------------------------------------------------------------------------------------------------------------
#!bin/bash
repository=pomis-toolbox
cd /data/git/$repository
git init share=true
touch /.git/git-daemon-export-ok
git daemon --reuseaddr --base-path=/data/git/ /data/git/
#------------------------------------------------------------------------------------------------------------------------------------------------
