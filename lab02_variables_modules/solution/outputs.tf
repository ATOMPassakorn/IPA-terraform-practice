output "server_id" {
  description = "ID of the web instance provisioned by the module"
  value       = module.web.instance_id
}

output "server_private_ip" {
  description = "Private IP of the web instance provisioned by the module"
  value       = module.web.private_ip
}
