output "public_server_names" {
  description = "List of public server names extracted using for expression and filter"
  value       = [for k, v in var.web_servers : k if v.is_public]
}

output "server_arn_map" {
  description = "Map of server name to instance ARN using map comprehension"
  value       = { for k, inst in aws_instance.servers : k => inst.arn }
}

output "subnet_ids" {
  description = "List of subnet IDs using splat operator or for expression"
  value       = [for s in aws_subnet.subnets : s.id]
}
