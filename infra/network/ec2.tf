data aws_ami latest_amazon_linux {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-*"]
  }
}

resource aws_instance instance {
  count                  = 1
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = var.project_name
  }
}

resource aws_security_group sg {
  name        = "http-ssh"
  description = "Allow HTTP + SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

#
# outputs
#

output public_dns {
  value = aws_instance.instance[0].public_dns
}

output public_ip {
  value = aws_instance.instance[0].public_ip
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
# }

# resource tls_private_key key {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource aws_key_pair generated_key {
#   key_name   = var.project_name
#   public_key = tls_private_key.key.public_key_openssh
# }

# resource local_file pem {
#   content  = tls_private_key.key.private_key_pem
#   filename = "ec2.pem"
# }