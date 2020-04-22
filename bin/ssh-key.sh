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


usage() {
    under usage ssh-key [command]    
    under commands 'create     create SSH keys + import public key to AWS
         delete     delete SSH keys + public key from AWS'

    if [[ -f $SSH_KEY.pub ]]
    then 
        under $SSH_KEY.pub 
        cat $SSH_KEY.pub
    fi
}


# create SSH keys + import public key to AWS
create() {
    if [[ ! -f $SSH_KEY.pub ]]
    then
        # SSH keys
        log create $SSH_KEY.pem + $SSH_KEY.pub keys — without passphrase
        ssh-keygen \
            -q \
            -t rsa \
            -N '' \
            -f $SSH_KEY.pem
        mv $SSH_KEY.pem.pub $SSH_KEY.pub
        chmod 400 $SSH_KEY.{pem,pub}

        # import to AWS
        log import $SSH_KEY.pub key to AWS EC2
        aws ec2 import-key-pair \
            --key-name $SSH_KEY \
            --public-key-material \
            file://./$SSH_KEY.pub
    else
        err abort $SSH_KEY.pub already exisits
    fi
}


# delete SSH keys + public key from AWS
delete() {
    if [[ -f $SSH_KEY.pub ]]
    then
        # SSH keys
        log delete $SSH_KEY.pem + $SSH_KEY.pub keys
        rm --force $SSH_KEY.{pem,pub}

        # from AWS
        log delete $SSH_KEY key from AWS EC2
        aws ec2 delete-key-pair \
            --key-name $SSH_KEY
    else
        err abort $SSH_KEY.pub not found
    fi
}


case $1 in
    create) create ;;
    delete) delete ;;
         *) usage ;;
esac
