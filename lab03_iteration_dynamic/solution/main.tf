data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "lab03-vpc"
  }
}

resource "aws_subnet" "subnets" {
  for_each   = toset(var.subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value

  tags = {
    Name = "subnet-${each.value}"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-firewall-sg"
  description = "Security group with dynamic ingress rules"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.firewall_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab03-sg"
  }
}

resource "aws_instance" "servers" {
  for_each = var.web_servers

  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type
  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  tags = {
    Name   = "server-${each.key}"
    Public = tostring(each.value.is_public)
  }
}
