#!/bin/bash

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

# Initialize our own variables:
repository=""
user=Dudy
password=yaq12wsx

if [ $# -eq 1 ] && [ ${1:0:1} != "-" ]; then
    repository=$1
else
    # A POSIX variable
    OPTIND=1         # Reset in case getopts has been used previously in the shell.

    while getopts "r:h" opt; do
        case "$opt" in
        r)  repository=$OPTARG
            ;;
        h)  exec 1<&6 6<&-
            exec 2<&7 7<&-
            echo "### usage: setupGit.sh <repositorName> or setupGit.sh -r <repositorName>"
            exit 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    [ "$1" = "--" ] && shift
fi

if [[ -z $repository ]]; then
    echo "### error: no repository name given (-r option)"
    echo "### usage: setupGit.sh <repositorName> or setupGit.sh -r <repositorName>"
    #  restore stdout from fd #6, where it had been saved, and stderr from fd #7
    exec 1<&6 6<&-
    exec 2<&7 7<&-
    exit -1
fi

echo "### using repository name '$repository'"

#################################################################
# create local directory for new project
#################################################################

mkdir $repository
cd $repository

#################################################################
# create repository on Github via API v3 and clone locally
#################################################################
    
echo "### create repository on Github via API v3 and clone locally"

# create repository on Github
user_password="'$user:$password'"
repo_name="'{\"name\": \""$repository"\", \"auto_init\": true}'"
command="curl -u $user_password https://api.github.com/user/repos -d $repo_name"
eval $command
echo "### remote Github repository '$repository' created"

# clone local beta repository from Github
git clone git@github.com:Dudy/$repository.git beta
cd beta
git remote set-url origin git@github.com:Dudy/$repository.git
echo "### local beta repository created"

#################################################################
# create local branches staging/development and push to Github
#################################################################

echo "### create local branches staging/development and push to Github"

# create new staging branch
git checkout -b staging
# push new branch to Github
git push -u origin staging
echo "### staging branch created"

# need to switch back to master branch to derive new branch from
git checkout master
# create new development branch
git checkout -b development
# push new branch to Github
git push -u origin development
echo "### staging development created"

#################################################################
# create local alpha repository from local beta
#################################################################

echo "### create local alpha repository from local beta"

# need to clone inside parent directory
cd ..
# just clone development branch from beta, also use beta as origin name
git clone ./beta/ -o beta -b development --single-branch ./alpha
# rename development branch to master
cd alpha
git branch -m development master
cd ..

echo "### local alpha repository created"

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

