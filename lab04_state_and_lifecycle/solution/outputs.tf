output "server_full_address" {
  description = "Combined server address showing dependency chain"
  value       = terraform_data.server.output
}
