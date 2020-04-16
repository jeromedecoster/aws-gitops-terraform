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

# echo $1 in underline magenta then $2 in cyan
err() {
    echo -e "\033[1;4;35m$1\033[0m \033[1;36m$2\033[0m" >&2
}

err delete 'total destruction in 5 seconds ...'
err warn 'press ctrl-c to abort ...'
sleep 5

if [[ -f $SSH_KEY.pub ]]
then
    log delete "$SSH_KEY.pem + $SSH_KEY.pub local keys"
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

log terraform destroy
terraform destroy \
    -var "ssh_key_name=$SSH_KEY" \
    -auto-approve