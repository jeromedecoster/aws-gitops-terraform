#!/bin/bash
echo ······ source settings.sh ······
cd $CODEBUILD_SRC_DIR
source settings.sh
echo ······ AWS_REGION=$AWS_REGION ······
echo ······ S3_BUCKET=$S3_BUCKET ······
echo ······ SSH_KEY=$SSH_KEY ······

echo ······ terraform init ······
cd infra
terraform init \
    -input=false \
    -backend=true \
    -backend-config="region=$AWS_REGION" \
    -backend-config="bucket=$S3_BUCKET" \
    -backend-config="key=terraform" \
    -no-color

NAME=$(terraform output | grep ^project_name | sed 's|.*= ||')
echo ······ NAME=$NAME ······

if [[ -n "$NAME" ]]; then
    ID=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names $NAME \
        --query "AutoScalingGroups[?AutoScalingGroupName == '$NAME'].Instances[*].[InstanceId]" \
        --output text)
    echo ······ ID=$ID ······

    if [[ -n "$ID" ]]; then
        echo ······ terminate EC2 instances ······
        echo "$ID" | while read line; do
            aws ec2 terminate-instances --instance-ids $line
        done
        echo ······ sleep 5 seconds ······
        sleep 5
    fi
    echo ······ delete auto scaling group ······
    aws autoscaling delete-auto-scaling-group \
        --auto-scaling-group-name $NAME \
        --force-delete
    echo ······ sleep 10 seconds ······
    sleep 10

    while [[ -n $(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names $NAME \
        --query "AutoScalingGroups[?AutoScalingGroupName == '$NAME']" \
        --output text) ]]; do
        aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names $NAME \
            --query "AutoScalingGroups[?AutoScalingGroupName == '$NAME'].[Status]" \
            --output text
        echo ······ waiting auto-scaling-group destruction. sleep 20 seconds ······
        sleep 20
    done
fi

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