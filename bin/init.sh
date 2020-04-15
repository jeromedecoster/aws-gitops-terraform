#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"
cd "$dir"

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

#
# Create SSH keys + import public key to AWS 
#

if [[ ! -f $SSH_KEY.pub ]]
then
    KEY=$(aws ec2 describe-key-pairs \
        --key-names $SSH_KEY \
        --query KeyPairs \
        --output text \
        2>/dev/null)
    if [[ -n "$KEY" ]]
    then
        err abort "the $SSH_KEY key already exists" 
        exit
    fi

    log create "$SSH_KEY.pem + $SSH_KEY.pub keys (without passphrase)"
    ssh-keygen \
        -q \
        -t rsa \
        -N '' \
        -f $SSH_KEY.pem
    mv $SSH_KEY.pem.pub $SSH_KEY.pub
    chmod 400 $SSH_KEY.{pem,pub}

    log import "$SSH_KEY.pub key to AWS EC2"
    aws ec2 import-key-pair \
        --key-name $SSH_KEY \
        --public-key-material \
        file://./$SSH_KEY.pub
fi

#
#
#

# cd "$dir"
# if [[ ! -f rand.txt ]]
# then
#     RAND=$(mktemp --dry-run XXXX)
#     echo $RAND > rand.txt
# fi

BUCKET=$(aws s3api list-buckets \
    --query 'Buckets[].Name' \
    --output text | grep $S3_BUCKET)

if [[ -z $BUCKET ]]
then
    log create "$S3_BUCKET bucket"
    aws s3 mb s3://$S3_BUCKET
fi

# infra init (a modifier)
terraform init \
    -input=false \
    -backend=true \
    -backend-config="region=eu-west-3" \
    -backend-config="bucket=$S3_BUCKET" \
    -backend-config="key=terraform"