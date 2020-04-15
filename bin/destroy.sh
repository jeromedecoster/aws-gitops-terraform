#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"
cd $dir

source settings.sh
cd infra

# log $1 in underline green then $2 in yellow
log() {
    echo -e "\033[1;4;32m$1\033[0m \033[1;33m$2\033[0m"
}

if [[ -f $SSH_KEY.pub ]]
then
    log delete "$SSH_KEY.pem + $SSH_KEY.pub keys"
    rm --force $SSH_KEY.pem
    rm --force $SSH_KEY.pub
fi

KEY=$(aws ec2 describe-key-pairs \
        --key-names $SSH_KEY \
        --query KeyPairs \
        --output text \
        2>/dev/null)
if [[ -n "$KEY" ]]
then
    log delete "$SSH_KEY key from AWS EC2"
    aws ec2 delete-key-pair \
        --key-name $SSH_KEY
fi

# terraform destroy -auto-approve