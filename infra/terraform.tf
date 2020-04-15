variable ssh_key_name {}

locals {
  project_name = "gitops-${random_id.random.hex}"
  region       = "eu-west-3"
}

provider aws {
  region = local.region
}

terraform {
  # 'backend-config' options must be passed like :
  # terraform init -input=false -backend=true \
  #   [with] -backend-config="backend.json"
  #     [or] -backend-config="backend.tfvars"
  #     [or] -backend-config="<key>=<value>"
  backend "s3" {}
}

resource random_id random {
  byte_length = 2
}

#
# modules
#

module network {
  source       = "./network"
  project_name = local.project_name
  ssh_key_name = var.ssh_key_name
}

#
# outputs
#

output public_dns {
  value = module.network.public_dns
}

output public_ip {
  value = module.network.public_ip
}