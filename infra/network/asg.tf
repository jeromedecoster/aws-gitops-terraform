# get id of the default VPC in the current region
# with `aws_default_vpc.default.id`
resource aws_default_vpc default_vpc {
}

output default_vpc_id {
  value = aws_default_vpc.default_vpc.id
}

# get names of the available AZ in current region
# with `data.aws_availability_zones.availability_zones.names`
data aws_availability_zones availability_zones {
  state = "available"
}

output default_vpc_az {
  value = data.aws_availability_zones.availability_zones.names
}

# get the subnets ids of the default VPC
# with `data.aws_subnet_ids.subnet_ids.ids`
data aws_subnet_ids subnet_ids {
  vpc_id = aws_default_vpc.default_vpc.id
}

output default_vpc_subnets {
  value = data.aws_subnet_ids.subnet_ids.ids
}

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



resource aws_launch_configuration launch_configuration {
  name          = var.project_name
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.security_group.id]

  user_data = file("${path.module}/user-data.sh")
}

resource aws_autoscaling_group default {
  name = var.project_name

  max_size         = 3
  min_size         = 1
  desired_capacity = 1

  launch_configuration = aws_launch_configuration.launch_configuration.name

  target_group_arns = [aws_lb_target_group.target_group.arn]

  vpc_zone_identifier = data.aws_subnet_ids.subnet_ids.ids
  #["subnet-43dbe42a", "subnet-ee46dda3", "subnet-f3d98f88"]
  #[data.aws_subnet_ids.subnet_ids.ids]
}

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource aws_lb lb {
  name               = var.project_name
  load_balancer_type = "application"

  #   internal        = false
  security_groups = [aws_security_group.security_group.id]
  subnets         = data.aws_subnet_ids.subnet_ids.ids
}

resource aws_lb_target_group target_group {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 10
    matcher             = "200"
  }
}

resource aws_lb_listener http {

  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}