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
    under commands 'init       terraform init the project infrastructure
         apply      terraform plan + apply the project infrastructure
         destroy    terraform destroy the project infrastructure'
}


init() {
    # terraform init
    log init terraform
    terraform init \
        -input=false \
        -backend=true \
        -backend-config="region=$AWS_REGION" \
        -backend-config="bucket=$S3_BUCKET" \
        -backend-config="key=terraform" \
        -reconfigure
}


apply() {
    # terraform plan
    log terraform plan
    terraform plan \
    -var "ssh_key_name=$SSH_KEY" \
    -out=terraform.plan && \

    # terraform apply
    log terraform apply && \
    terraform apply \
        -auto-approve \
        terraform.plan
}


destroy() {
    # terraform destroy
    log terraform destroy
    terraform destroy \
        -var "ssh_key_name=$SSH_KEY" \
        -auto-approve
}

case $1 in
       init) init ;;
      apply) apply ;;
    destroy) destroy ;;
          *) usage ;;
esac
