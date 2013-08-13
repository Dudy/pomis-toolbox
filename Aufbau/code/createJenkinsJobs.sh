#!/bin/bash

project=dummy
repository=alpha
template_dir=/usr/lib/projectInit/templates
new_url=/data/git/$project/$repository
branch=master
template_name=jenkinsJob.xml

old_dir=${PWD}
timestamp=`date -u '+%Y%m%d%H%M%S%N'`
temp_dir=/tmp/jenkinsJob_$timestamp
counter=0

mkdir $temp_dir
cd $temp_dir

function createJob() {
    formatted_counter=`printf %02d ${counter##}`
    job_name=${project}_${formatted_counter}_${1}
    temp_job_config=$job_name.xml
    jenkins_command=${1}.sh
    
    cp $template_dir/$template_name $temp_dir/$temp_job_config
    sed -i "s,###URL###,$new_url,g" $temp_dir/$temp_job_config
    sed -i "s,###BRANCH###,$branch,g" $temp_dir/$temp_job_config
    sed -i "s,###COMMAND###,$jenkins_command,g" $temp_dir/$temp_job_config

    command="curl -i -H 'Content-Type: text/xml' -X POST -d @$temp_job_config http://192.168.226.128:8080/createItem?name=$job_name"
    
    eval $command > $old_dir/$job_name-jenkins.output
    
    counter=$[$counter +1]
}

createJob buildTest
createJob unitTest
createJob integrationTest
createJob systemTest
createJob acceptanceTest

rm -rf $temp_dir