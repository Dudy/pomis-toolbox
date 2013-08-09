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

rootdir=$directory$repository
mkdir $rootdir
cd $rootdir

#################################################################
# create repository on Github via API v3
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

cd $rootdir

#################################################################
# create local alpha and beta repositories
#################################################################

echo "### create local alpha and beta repositories"

# clone local beta repository from Github
git clone git@github.com:$username/$repository.git beta
# clone local alpha from local beta and detach it (pushes will be
# mediated by the omega repository)
git clone beta alpha
cd alpha
git remote rm origin

echo "### created local alpha and beta repositories"

cd $rootdir

#################################################################
# create testing branches on beta
#################################################################

echo "### create testing branches on beta"

cd beta

# create new test branches
git branch acceptancetests
git branch systemtests
git branch integrationtests
git branch unittests
echo "### test branches created"

# initialization of beta finished, now make it a bare "server" repository
git config --bool core.bare true

echo "### created testing branches on beta"

cd $rootdir

#################################################################
# create omega from alpha, add beta as remote
#################################################################

echo "### create omega from alpha, add beta as remote"

git clone alpha omega
cd omega
git remote rename origin alpha
git remote add beta $rootdir/beta
git remote -v

echo "### creation of omega repository finished"

cd $rootdir

#################################################################
# restore stdout and stderr and exit
#################################################################

echo "### restore stdout and stderr and exit"

#  restore stdout from fd #6, where it had been saved, and stderr from fd #7
exec 1<&6 6<&-
exec 2<&7 7<&-
exit 0

#################################################################
# end of file
#################################################################



# all of the following are notes for future use in this or other scripts



































#################################################################
# mit --share fügt git beim Anlegen eines Repositories Gruppenschreibrechte hinzu
# später (auf omega repo):
#   git checkout dev
# git merge alpha master

#######################

#################################################################
# use omega repository as follows
# this is all in one run, I should make several distinct steps
# in Jenkins of this
#################################################################
#
## step 1
#cd omega
#git pull alpha
#
#success=buildApplication.sh
#if [ !$success ]; then
#	echo "### error in buildAllpication.sh"
#	echo "### rolling back changes"
#	# TODO: mark as FAILED
#	# TODO: roll back changes
#	# TODO: send message to the developer that committed this
#	exit -1
#fi
#
## step 2
#success=runUnittests.sh
#if [ !$success ]; then
#	echo "TODO: error in runUnittests.sh"
#	echo "### rolling back changes"
#	# TODO: mark as FAILED
#	# TODO: roll back changes
#	# TODO: send message to the developer that committed this
#	exit -2
#fi
#
#git push beta master:development
#
## step 3
#success=runIntegrationtests.sh
#if [ !$success ]; then
#	echo "TODO: error in runIntegrationtests.sh"
#	# TODO: mark as FAILED
#	# TODO: send message all the developers
#	exit -3
#fi
#
#git push beta master:staging
#
## step 4
#success=runSystemtests.sh
#if [ !$success ]; then
#	echo "TODO: error in runSystemtests.sh"
#	# TODO: mark as FAILED
#	# TODO: send message all the developers
#	exit -4
#fi
#
#git push beta master:master
#
#######################


#git clone --bare ~/proj proj.git
#touch proj.git/git-daemon-export-ok
#curl -i -u username -d '{"scopes":["public_repo"]}' https://api.github.com/authorizations
 
 
 
 
