#
# variables defined in `terraform.tfvars`
#

variable github_token {}
variable github_owner {}
variable github_repository_name {}

#
# locals
#

locals {
  project_name = "gitops-terraform-${random_id.random.hex}"
  region       = "eu-west-3"
}

provider aws {
  region = local.region
}

resource random_id random {
  byte_length = 3
}

#
# outputs
#

output project_name {
  value = local.project_name
}
