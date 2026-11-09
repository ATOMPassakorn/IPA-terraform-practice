module "web" {
  source = "./modules/web_app"

  instance_type = local.computed_instance_type
  server_name   = "${local.project_name}-${var.environment}-web"

  volume_config = {
    size_gb   = local.is_production ? 30 : 10
    encrypted = true
  }

  tags = local.common_tags
}
