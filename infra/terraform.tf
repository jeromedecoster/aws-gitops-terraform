# variable project_name {}
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

# module network {
#   source       = "./network"
#   project_name = local.project_name
#   ssh_key_name = var.ssh_key_name
# }

#
# outputs
#

output project_name {
  value = local.project_name
}

# output public_dns {
#   value = module.network.public_dns
# }

# output public_ip {
#   value = module.network.public_ip
# }

# tests

# resource "aws_default_vpc" "default_vpc" {
# }

# output default_vpc {
#   value = aws_default_vpc.default_vpc.id
# }

# data "aws_availability_zones" "available" {
#   state = "available"
# }

# output default_availability_zones {
#   value = data.aws_availability_zones.available.names
# }

# output proj {
#   value = local.project_name
# }
# data aws_subnet_ids subnet_ids {
#   vpc_id = aws_default_vpc.default_vpc.id
# }

# output default_vpc_subnets {
#   value = data.aws_subnet_ids.subnet_ids.ids
# }