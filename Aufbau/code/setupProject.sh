#!/bin/bash

#################################################################
# functions
#################################################################

function usageAndExit() {
    # goes to logfile
    
    echo "### usage: setupProject [-d <directory>] -u <username> -p <password> -n <name>"
    echo "###        directory:  [optional] the directory to create the new project in, defaults to current directory"
    echo "###        username:   the username on Github"
    echo "###        password:   the password on Github"
    echo "###        project: the name of the project to create"
    
    #  restore stdout from fd #6, where it had been saved, and stderr from fd #7
    exec 1<&6 6<&-
    exec 2<&7 7<&-
    
    # goes to command line
    echo " usage: setupProject [-d <directory>] -u <username> -p <password> -n <name>"
    echo "        directory:  [optional] the directory to create the new project in, defaults to current directory"
    echo "        username:   the username on Github"
    echo "        password:   the password on Github"
    echo "        project: the name of the project to create"
    
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
project=""
username=""
password=""
directory=""

# a POSIX variable
OPTIND=1         # reset in case getopts has been used previously in the shell.

while getopts "d:n:p:u:h" opt; do
    case "$opt" in
        d)  directory=$OPTARG
            ;;
        n)  project=$OPTARG
            ;;
        p)  password=$OPTARG
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

if [[ -z $project ]]; then
    echo "### error: no project name given (-n option)"
    usageAndExit -3
fi

if [[ -z $username ]]; then
    echo "### error: no username given (-u option)"
    usageAndExit -4
fi

echo "### using project name '$project' in directory '$directory'"

#################################################################
# create local directory for new project
#################################################################

rootdir=$directory$project
mkdir $rootdir
cd $rootdir

#################################################################
# create repository on Github via API v3 for this project
#################################################################
    
echo "### create repository on Github via API v3 and clone locally"

# create repository on Github using API v3
username_password="'$username:$password'"
parameter="'{\"name\": \""$project"\", \"auto_init\": true, \"bare\": true}'"
command="curl -u $username_password https://api.github.com/user/repos -d $parameter"
echo "### command:"
echo "### $command"
eval $command

echo "### remote Github repository '$project' created"

cd $rootdir

#################################################################
# create local test and development repositories
#################################################################

echo "### create local test and development repositories"

# clone local test repository from Github
git clone git@github.com:$username/$project.git test
# clone local development from local test and detach it (pushes will be
# mediated by explicit test stage repositories)
git clone --bare test development.git
cd development.git
git remote rm origin

echo "### created local test and development repositories"

cd $rootdir

#################################################################
# create testing branches on test repository
#################################################################

echo "### create testing branches on test repository"

cd test

# create new test branches for storing project data
git branch acceptancetests
git branch systemtests
git branch integrationtests
git branch unittests
echo "### test branches created"

# initialization of test finished, now make it a bare "server" repository
mv .git .. && rm -fr *
mv ../.git .
mv .git/* .
rmdir .git
git config --bool core.bare true
cd ..;
mv test test.git # renaming just for clarity

echo "### created testing branches on test"

cd $rootdir

#################################################################
# create distinct test stage repositories
#################################################################

echo "### create distinct test stage repositories"

### create new test repositories for testing the application

# test:master <=> acceptancetests:master
git clone test -b master -o master --single-branch acceptancetests
# test:acceptancetests <=> systemtests:master
git clone test -b acceptancetests -o acceptancetests --single-branch systemtests
cd systemtests
git branch -m acceptancetests master
cd ..
# test:systemtests <=> integrationtests:master
git clone test -b systemtests -o systemtests --single-branch integrationtests
cd integrationtests
git branch -m systemtests master
cd ..
# test:integrationtests <=> unittests:master
git clone test -b integrationtests -o integrationtests --single-branch unittests
cd unittests
git branch -m integrationtests master
cd ..
# test:unittests <=> buildtests:master
git clone test -b unittests -o unittests --single-branch buildtests
cd buildtests
git branch -m unittests master
cd ..

# the build test stage repository is also connected to the development
# repository to get the user changes into the test loop
cd buildtests
git remote add development $rootdir/development.git
git remote -v

echo "### creation distinct test stage repositories finished"

cd $rootdir

#################################################################
# create jenkins jobs
#################################################################

# TODO: ist bisher in createJenkinsJobs.sh ausgelagert

#################################################################
# initialize repositories 1
#################################################################

echo "### initialize repositories 2 - adding hooks"

# TODO: git hooks einrichten

echo "### finished initializing repositories"

cd $rootdir

#################################################################
# initialize repositories 2
#################################################################

echo "### initialize repositories 2 - adding scripts"

# hint: initialization of all repositories and branches here is done
# the same way that the productive workflow later on is meant to be,
# that is: test scripts are added to a local clone of the development
# repository and are committed and pushed to the server. As all scripts
# will return 0 at initial stage (indicating success) all tests will
# pass and all changes are propagated throughout all the test stages.

# work takes place in a temporary directory
temp_dir=/tmp/initGit_$timestamp
mkdir $temp_dir
cd $temp_dir

# use templates
template_dir=`dirname $0`/templates

# clone development repository
git clone $rootdir/development.git temp_development

# add files to development repository
for f in *.sh
do
    echo "### copy $template_dir/$f to $temp_dir/temp_development"
    cp $template_dir/$f $temp_dir/temp_development
    chmod 777 $temp_dir/temp_development/$f
done

# add to repository
cd $temp_dir/temp_development
git add .
git commit -m 'added test scripts'
echo "### added and comitted scripts"
git push origin master
echo "### changes pushed to origin"

# clean up
cd $rootdir
rm -rf $temp_dir

echo "### finished initializing repositories"

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






















































#################################################################
# TODO
#################################################################
# [ ] 
