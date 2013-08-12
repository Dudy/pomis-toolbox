#!/bin/bash

timestamp=`date -u '+%Y%m%d%H%M%S%N'`

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
        d)      directory=$OPTARG
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
cd $rootdir

#################################################################
# initialize repositories
#################################################################

# hint: initialization of all repositories and branches here is done
# the same way that the productive workflow later on is meant to be

# work takes place in a temporary directory
temp_dir=/tmp/initGit_$timestamp
mkdir $temp_dir
cd $temp_dir

# use templates
template_dir=/usr/lib/projectInit/templates
template_name=buildApplication.sh.template
new_name=${template_name::-9} # remove last nine characters (".template")

# clone alpha repository
git clone $rootdir/alpha temp_alpha

# add files to alpha repository
cp $template_dir/$template_name $temp_dir/temp_alpha/$new_name
chmod 777 $temp_dir/temp_alpha/$new_name
# for later usage, if some content has to be changed
#sed -i "s,###PLACEHOLDER###,$new_value,g" $temp_dir/temp_alpha/$new_name

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
# use omega project as follows
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
#       echo "### error in buildAllpication.sh"
#       echo "### rolling back changes"
#       # TODO: mark as FAILED
#       # TODO: roll back changes
#       # TODO: send message to the developer that committed this
#       exit -1
#fi
#
## step 2
#success=runUnittests.sh
#if [ !$success ]; then
#       echo "TODO: error in runUnittests.sh"
#       echo "### rolling back changes"
#       # TODO: mark as FAILED
#       # TODO: roll back changes
#       # TODO: send message to the developer that committed this
#       exit -2
#fi
#
#git push beta master:development
#
## step 3
#success=runIntegrationtests.sh
#if [ !$success ]; then
#       echo "TODO: error in runIntegrationtests.sh"
#       # TODO: mark as FAILED
#       # TODO: send message all the developers
#       exit -3
#fi
#
#git push beta master:staging
#
## step 4
#success=runSystemtests.sh
#if [ !$success ]; then
#       echo "TODO: error in runSystemtests.sh"
#       # TODO: mark as FAILED
#       # TODO: send message all the developers
#       exit -4
#fi
#
#git push beta master:master
#
#######################


#git clone --bare ~/proj proj.git
#touch proj.git/git-daemon-export-ok
#curl -i -u username -d '{"scopes":["public_repo"]}' https://api.github.com/authorizations
 
 
 
 


