# get id of the default VPC in the current region
# with `aws_default_vpc.default.id`
resource aws_default_vpc default_vpc {
}

# output default_vpc_id {
#   value = aws_default_vpc.default_vpc.id
# }

# get names of the available AZ in current region
# with `data.aws_availability_zones.availability_zones.names`
data aws_availability_zones availability_zones {
  state = "available"
}

# output default_vpc_az {
#   value = data.aws_availability_zones.availability_zones.names
# }

# get the subnets ids of the default VPC
# with `data.aws_subnet_ids.subnet_ids.ids`
data aws_subnet_ids subnet_ids {
  vpc_id = aws_default_vpc.default_vpc.id
}

# output default_vpc_subnets {
#   value = data.aws_subnet_ids.subnet_ids.ids
# }

# get the AMI id of the latest "Amazon Linux 2 AMI (HVM)" (Free tier eligible)
# with `data.aws_ami.latest_amazon_linux.id`
data aws_ami latest_amazon_linux {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-*"]
  }
}