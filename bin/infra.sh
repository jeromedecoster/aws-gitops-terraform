#!/bin/bash

# the bin directory, containing this script file
bin="$(cd "$(dirname "$0")"; pwd)"
# source {under,log,err} functions
source "$bin/common.sh"

# go to the project root directory
cd "$bin/.."
if [[ -f settings.sh ]]
then source settings.sh
else err abort settings.sh not found; exit
fi

# go to the infra directory
cd "$bin/../infra"

usage() {
    under usage infra.sh [command]    
#     under commands 'init     create terraform.tfvars + terraform init
#          apply    terraform plan + terraform apply'

# if [[ -f terraform.tfvars ]]
# then
#     under terraform.tfvars 
#     cat terraform.tfvars
#     echo
# fi
}


init() {
    log init terraform
    # terraform init
    terraform init \
        -input=false \
        -backend=true \
        -backend-config="region=$AWS_REGION" \
        -backend-config="bucket=$S3_BUCKET" \
        -backend-config="key=terraform" \
        -reconfigure
    
    # if [[ ! -f terraform.tfvars ]]
    # then
    #     log create terraform.tfvars file
    #     # copy `terraform.sample.tfvars` as `terraform.tfvars` without overwriting
    #     cp --no-clobber terraform.sample.tfvars terraform.tfvars
    #     err warn you must define $(realpath terraform.tfvars)
    #     under terraform.tfvars ''
    #     cat terraform.tfvars
    #     echo
    # fi
}


apply() {
    # if [[ ! -f terraform.tfvars ]]
    # then err abort terraform.tfvars not found; exit
    # fi
    
    # if [[ $(grep token terraform.tfvars | sed 's|.*= "||' | wc -m) -lt 10 ]]
    # then err abort github_token not defined; exit
    # fi

    log terraform plan
    terraform plan \
    -var "ssh_key_name=$SSH_KEY" \
    -out=terraform.plan && \

    log terraform apply && \
    terraform apply \
        -auto-approve \
        terraform.plan
    # log terraform apply && \
    # terraform apply \
    #     -auto-approve \
    #     terraform.plan
}


case $1 in
     init) init ;;
    apply) apply ;;
        *) usage ;;
esac
