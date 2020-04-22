.SILENT:

help:
	grep --extended-regexp '^[a-zA-Z-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-32s\033[0m%s\n", $$1, $$2 }'

# init: # terraform init + create ssh keys and passphrase
# 	bin/init.sh

# validate: # terraform format then validate
# 	cd infra; \
# 	terraform fmt -recursive; \
# 	terraform validate

# apply: validate # terraform plan then apply with auto approve (invoke first validate)
# 	bin/apply.sh

# connect:
# 	bin/connect.sh
# 	# cd infra; \
# 	# ssh -i "gitops-terraform.pem" ec2-user@ec2-35-180-116-216.eu-west-3.compute.amazonaws.com

# destroy: # destroy everything with auto approve
# 	bin/destroy.sh

# local-init: # aa
# 	bin/local-init.sh

# local-apply: # aa
# 	bin/local-apply.sh

# deploy-init: # aa
# 	bin/deploy-init.sh



setup-create: # create the settings.sh files + the AWS S3 bucket
	bin/setup.sh create

setup-delete: # delete SSH keys + public key from AWS
	bin/setup.sh delete


ssh-key-create: # create SSH keys + import public key to AWS
	bin/ssh-key.sh create

ssh-key-delete: # delete SSH keys + public key from AWS
	bin/ssh-key.sh 

deployment-pipeline-init: # create terraform.tfvars + terraform init the deployment pipeline
	bin/deployment-pipeline.sh init

deployment-pipeline-validate: # terraform validate the deployment pipeline
	cd deployment-pipeline; \
	terraform fmt -recursive; \
	terraform validate

deployment-pipeline-apply: # terraform plan + terraform apply the deployment pipeline
	bin/deployment-pipeline.sh apply

deployment-pipeline-destroy: # terraform destroy the deployment pipeline
	bin/deployment-pipeline.sh destroy


infra-init: # terraform init the project infrastructure
	bin/infra.sh init

infra-validate: # terraform validate the project infrastructure
	cd infra; \
	terraform fmt -recursive; \
	terraform validate

infra-apply: # terraform plan + apply the project infrastructure
	bin/infra.sh apply

infra-destroy: # terraform destroy the project infrastructure
	bin/infra.sh destroy