locals {
  is_production  = var.environment == "prod"
  cluster_prefix = "${var.project_name}-${var.environment}"

  # Environment-driven sizing for cluster nodes
  cluster_nodes = {
    "frontend" = {
      instance_type = local.is_production ? "t3.medium" : "t3.micro"
      disk_gb       = local.is_production ? 50 : 20
    }
    "backend" = {
      instance_type = local.is_production ? "t3.medium" : "t3.micro"
      disk_gb       = local.is_production ? 50 : 20
    }
  }

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
