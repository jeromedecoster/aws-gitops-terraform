#!/bin/bash

# the bin directory, containing this script file
bin="$(cd "$(dirname "$0")"; pwd)"
# source {under,log,err} functions
source "$bin/common.sh"
# go to the project root directory
cd "$bin/.."

usage() {
    under usage setup [command]    
    under commands 'create     create the settings.sh files + the AWS S3 bucket
         delete     delete the settings.sh files + the AWS S3 bucket'

if [[ -f settings.sh ]]
then 

    under settings.sh 
    cat settings.sh
fi
}

# create settings.sh file + S3 bucket
create() {
    if [[ ! -f settings.sh ]]
    then
        # settings.sh
        log create settings.sh
        S3_BUCKET=gitops-terraform-$(mktemp --dry-run XXXX | tr '[:upper:]' '[:lower:]')
        cat > settings.sh << EOF
AWS_REGION=eu-west-3
SSH_KEY=gitops-terraform
S3_BUCKET=$S3_BUCKET
EOF
        # S3 bucket
        log create $S3_BUCKET bucket
        aws s3 mb s3://$S3_BUCKET
    else 
        err abort settings.sh already exisits
    fi
}

# delete settings.sh file + S3 bucket
delete() {
    if [[ -f settings.sh ]]
    then
        # S3 bucket
        log delete $S3_BUCKET bucket
        aws s3 rb s3://$S3_BUCKET --force

        # settings.sh
        log delete settings.sh
        rm settings.sh
    else
        err abort settings.sh not found
    fi
}

case $1 in
    create) create ;;
    delete) delete ;;
         *) usage ;;
esac
