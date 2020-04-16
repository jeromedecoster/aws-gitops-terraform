#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"
cd $dir

source settings.sh
cd infra

DNS=$(terraform output | grep ^public_dns | sed 's|.*= ||')

ssh -i "$SSH_KEY.pem" ec2-user@$DNS