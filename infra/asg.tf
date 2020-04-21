resource aws_security_group security_group {
  name        = local.project_name
  description = "Allow All"

  # inbound rule: all traffic, all protocol, all ranges  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rule: all traffic, all protocol, all ranges  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_launch_configuration launch_configuration {
  name          = local.project_name
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.security_group.id]

  user_data = file("${path.module}/user-data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_autoscaling_group default {
  name = local.project_name

  max_size         = 3
  min_size         = 1
  desired_capacity = 2

  launch_configuration = aws_launch_configuration.launch_configuration.name

  target_group_arns = [aws_lb_target_group.target_group.arn]

  vpc_zone_identifier = data.aws_subnet_ids.subnet_ids.ids

  lifecycle {
    create_before_destroy = true
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource aws_lb lb {
  name               = local.project_name
  load_balancer_type = "application"

  security_groups = [aws_security_group.security_group.id]
  subnets         = data.aws_subnet_ids.subnet_ids.ids
}

resource aws_lb_target_group target_group {
  name     = "${local.project_name}-tg"
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

output lb_dns {
  value = aws_lb.lb.dns_name
}