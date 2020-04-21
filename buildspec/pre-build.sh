#!/bin/bash
echo ······ install terraform ······
cd /usr/bin
curl -s -qL -o terraform.zip https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip -o terraform.zip
# cd $CODEBUILD_SRC_DIR/infra
# echo ·· terraform validate ··
# terraform validate -no-color