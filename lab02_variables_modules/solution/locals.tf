locals {
  project_name  = "ipa-practice"
  is_production = var.environment == "prod"

  # Ternary expression
  computed_instance_type = local.is_production ? "t3.small" : "t3.micro"

  common_tags = {
    Project     = local.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
