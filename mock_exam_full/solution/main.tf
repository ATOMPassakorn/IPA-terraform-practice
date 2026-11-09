resource "aws_vpc" "main" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_prefix}-vpc"
  })
}

resource "aws_security_group" "cluster_sg" {
  name        = "${local.cluster_prefix}-sg"
  description = "Security group with dynamic ingress rules for mock exam"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

module "app_cluster" {
  source = "./modules/service_cluster"

  cluster_name = local.cluster_prefix
  environment  = var.environment
  node_specs   = local.cluster_nodes
  tags         = local.common_tags
}
