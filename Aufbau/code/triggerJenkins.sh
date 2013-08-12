#!/bin/bash

timestamp=`date -u '+%Y%m%d%H%M%S%N'`
temp_dir=/tmp/jenkinsJob_$timestamp
mkdir $temp_dir
cd $temp_dir

template_dir=/usr/lib/projectInit/templates
template_name=jenkinsJob.xml.template
temp_job_config=temp_${template_name::-9} # remove last nine characters (".template")
new_url=/data/git/dummy/alpha

sed "s,###URL###,$newURL,g" $template_dir/$template_name > $temp_dir/$temp_job_config

command="curl -i -H 'Content-Type: text/xml' -X POST -d @$temp_job_config http://192.168.226.128:8080/createItem?name=$temp_job_config"

echo $command
eval $command
