# Simulation of Remote State lookup
# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = "ipa-tfstate-bucket"
#     key    = "network/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

# State-only resources for practice
resource "terraform_data" "primary_db" {
  input = "db-production-cluster-01"
}

resource "terraform_data" "app" {
  input = "web-frontend-app"

  triggers_replace = [
    terraform_data.primary_db.output
  ]
}

# Example of Terraform 1.5+ import block
# import {
#   to = aws_s3_bucket.legacy_logs
#   id = "company-legacy-logs-bucket"
# }
