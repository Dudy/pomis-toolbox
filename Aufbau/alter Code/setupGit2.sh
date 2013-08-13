#!/bin/bash

#################################################################
# functions
#################################################################

function usageAndExit() {
    # goes to logfile
	echo "### usage: setupGit.sh [-d <directory>] -u <username> -p <password> -r <repository>"
	echo "###        directory:  [optional] the directory to create the new repository in, defaults to current directory"
	echo "###        username:   the username on Github"
	echo "###        password:   the password on Github"
	echo "###        repository: the name of the repository to create"
	
	#  restore stdout from fd #6, where it had been saved, and stderr from fd #7
	exec 1<&6 6<&-
	exec 2<&7 7<&-
	
	# goes to command line
	echo "usage: setupGit.sh [-d <directory>] -u <username> -p <password> -r <repository>"
	echo "       directory:  [optional] the directory to create the new repository in, defaults to current directory"
	echo "       username:   the username on Github"
	echo "       password:   the password on Github"
	echo "       repository: the name of the repository to create"
	
	if [ $# -ne 1 ] ; then
		$1=1
	fi
	exit $1
}

#################################################################
# redirect stdout and stderr for logging to file
#################################################################

# on error goto hell
set -e

# link file descriptor #6 with stdout and #7 with stderr
exec 6<&1
exec 7<&2

# redirect all output to log file
timestamp=`date -u '+%Y%m%d%H%M%S%N'`
logfile=./log_setupGit_$timestamp.log
exec &>$logfile

#####################################################
# parse command line arguments
#####################################################

# initialize our own variables
repository=""
username=""
password=""
directory=""

# a POSIX variable
OPTIND=1         # reset in case getopts has been used previously in the shell.

while getopts "d:p:r:u:h" opt; do
	case "$opt" in
	d)	directory=$OPTARG
		;;
	p)  password=$OPTARG
		;;
	r)  repository=$OPTARG
		;;
	u)  username=$OPTARG
		;;
	h)  usageAndExit 1
		;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [[ -z $directory ]]; then
    directory=${PWD}
	
	# add trailing slash if there is no
	case $directory in
		*/) ;;
		*) directory=$directory/;;
	esac
fi

if [[ -z $password ]]; then
    echo "### error: no password given (-p option)"
    usageAndExit -2
fi

if [[ -z $repository ]]; then
    echo "### error: no repository name given (-r option)"
    usageAndExit -3
fi

if [[ -z $username ]]; then
    echo "### error: no username given (-u option)"
    usageAndExit -4
fi

echo "### using repository name '$repository' in directory '$directory'"

#################################################################
# create local directory for new project
#################################################################

mkdir $directory$repository
cd $directory$repository #this will be our root directory

#################################################################
# create repository on Github via API v3 and clone locally
#################################################################
    
echo "### create repository on Github via API v3 and clone locally"

# create repository on Github using API v3
username_password="'$username:$password'"
parameter="'{\"name\": \""$repository"\", \"auto_init\": true, \"bare\": true}'"
command="curl -u $username_password https://api.github.com/user/repos -d $parameter"
echo "### command:"
echo "### $command"
eval $command
echo "### remote Github repository '$repository' created"

# clone local beta repository from Github
git clone git@github.com:$username/$repository.git beta

#################################################################
# create local branches staging/development and push to Github
#################################################################

echo "### create local branches staging/development and push to Github"

cd beta
# create new staging branch
git checkout -b staging
echo "### staging branch created"

# need to switch back to master branch to derive new branch from
git checkout master
# create new development branch
git checkout -b development
echo "### development branch created"

# initialization of beta finished, now make it a bare "server" repository
git config --bool core.bare true
echo "### creation of beta repository finished"

cd ..

#################################################################
# create local alpha repository from local beta
#################################################################

echo "### create local alpha repository from local beta"

# just clone development branch from beta, also use beta as origin name
# make it bare as it should be the "server" repository for development
git clone --bare ./beta/ -b development --single-branch ./alpha
# rename development branch to master
cd alpha
git branch -m development master

echo "### creation of alpha repository finished"

						#################################################################
						# create local omega repository, add alpha and beta as remotes
						#################################################################

						echo "### create local omega repository"

						# need to clone inside parent directory
						cd ..
						# just clone development branch from beta, add alpha later on
						git clone ./beta/ -b development --single-branch ./alpha
						# rename development branch to master
						cd alpha
						git branch -m development master
						cd ..

						echo "### creation of alpha repository finished"

#################################################################
# restore stdout and stderr and exit
#################################################################

echo "### restore stdout and stderr and exit"

# back to parent dir
cd ..

#  restore stdout from fd #6, where it had been saved, and stderr from fd #7
exec 1<&6 6<&-
exec 2<&7 7<&-
exit 0

#################################################################
# end of file
#################################################################






# mit --share fügt git beim Anlegen eines Repositories Gruppenschreibrechte hinzu
# später (auf omega repo):
#   git checkout dev
# git merge alpha master

 omega muß alpha:master in seinen
 
git remote add <name> /path/to/other/repo/.git
git fetch <name>
git branch <name> <name>/master #optional



git clone beta omega
cd omega
git remote add alpha ../alpha

remote branches
	alpha/master
	beta/development

git push origin localbranch:remotebranch


#################################################################
# create omega from alpha, add beta as remote
#################################################################
git clone alpha omega
cd omega
git remote add beta ../beta
cd ..

#################################################################
# use omega repository as follows
# this is all in one run, I should make several distinct steps
# in Jenkins of this
#################################################################

# step 1
cd omega
git pull alpha

success=buildApplication.sh
if [ !$success ]; then
	echo "### error in buildAllpication.sh"
	echo "### rolling back changes"
	# TODO: mark as FAILED
	# TODO: roll back changes
	# TODO: send message to the developer that committed this
	exit -1
fi

# step 2
success=runUnittests.sh
if [ !$success ]; then
	echo "TODO: error in runUnittests.sh"
	echo "### rolling back changes"
	# TODO: mark as FAILED
	# TODO: roll back changes
	# TODO: send message to the developer that committed this
	exit -2
fi

git push beta master:development

# step 3
success=runIntegrationtests.sh
if [ !$success ]; then
	echo "TODO: error in runIntegrationtests.sh"
	# TODO: mark as FAILED
	# TODO: send message all the developers
	exit -3
fi

git push beta master:staging

# step 4
success=runSystemtests.sh
if [ !$success ]; then
	echo "TODO: error in runSystemtests.sh"
	# TODO: mark as FAILED
	# TODO: send message all the developers
	exit -4
fi

git push beta master:master








$ git clone --bare ~/proj proj.git
$ touch proj.git/git-daemon-export-ok
 
 
 curl -i -u username -d '{"scopes":["public_repo"]}' https://api.github.com/authorizations
 
 
 
 
