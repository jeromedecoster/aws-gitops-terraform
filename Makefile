.SILENT:

help:
	grep --extended-regexp '^[a-zA-Z]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-12s\033[0m%s\n", $$1, $$2 }'

init: # terraform init + create ssh keys and passphrase
	bin/init.sh

validate: # terraform format then validate
	cd infra; \
	terraform fmt -recursive; \
	terraform validate

apply: validate # terraform plan then apply with auto approve (invoke first validate)
	bin/apply.sh

connect:
	bin/connect.sh
	# cd infra; \
	# ssh -i "gitops-terraform.pem" ec2-user@ec2-35-180-116-216.eu-west-3.compute.amazonaws.com

destroy: # destroy everything with auto approve
	bin/destroy.sh

local-init:
	bin/local-init.sh

local-apply:
	bin/local-apply.sh