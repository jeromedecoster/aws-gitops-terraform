# # https://www.terraform.io/docs/providers/aws/r/vpc.html
# resource aws_vpc vpc {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = var.project_name
#   }
# }

# # https://www.terraform.io/docs/providers/aws/d/availability_zones.html
# data aws_availability_zones available {}

# # https://www.terraform.io/docs/providers/aws/d/subnet.html
# # https://www.terraform.io/docs/configuration/functions/cidrsubnet.html
# resource aws_subnet public {
#   count = length(data.aws_availability_zones.available.names)
#   // 3 availability zones give : 10.0.1.0/24 + 10.0.1.0/24 + 10.0.1.0/24
#   cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   vpc_id                  = aws_vpc.vpc.id
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "${var.project_name}-${count.index}"
#   }
# }

# # https://www.terraform.io/docs/providers/aws/d/internet_gateway.html
# resource aws_internet_gateway igw {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = var.project_name
#   }
# }

# # https://www.terraform.io/docs/providers/aws/d/route.html
# resource aws_route internet_access {
#   route_table_id         = aws_vpc.vpc.main_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw.id
# }

# # https://www.terraform.io/docs/providers/aws/d/security_group.html
# resource aws_security_group sg {

#   name   = var.project_name
#   vpc_id = aws_vpc.vpc.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.vpc.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }