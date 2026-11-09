output "primary_db_id" {
  description = "ID of primary db resource"
  value       = terraform_data.primary_db.id
}

output "app_status" {
  description = "Current application trigger output"
  value       = terraform_data.app.output
}
