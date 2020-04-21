#!/bin/bash
echo ······ source settings.sh ······
cd $CODEBUILD_SRC_DIR
source settings.sh
echo >>> AWS_REGION=$AWS_REGION
echo >>> S3_BUCKET=$S3_BUCKET
echo >>> SSH_KEY=$SSH_KEY

echo ······ terraform init ······
cd infra
terraform init \
    -input=false \
    -backend=true \
    -backend-config="region=$AWS_REGION" \
    -backend-config="bucket=$S3_BUCKET" \
    -backend-config="key=terraform" \
    -no-color

echo ······ terraform plan ······
terraform plan \
    -var "ssh_key_name=$SSH_KEY" \
    -out=terraform.plan \
    -no-color

echo ······ terraform apply ······
terraform apply \
    -auto-approve \
    terraform.plan \
    -no-color