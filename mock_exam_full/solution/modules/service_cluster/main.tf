data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "nodes" {
  for_each = var.node_specs

  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type

  root_block_device {
    volume_size = each.value.disk_gb
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}"
  })
}
