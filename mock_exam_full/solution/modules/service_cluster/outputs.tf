output "node_ids" {
  description = "Map of node name to instance ID"
  value       = { for k, inst in aws_instance.nodes : k => inst.id }
}

output "node_private_ips" {
  description = "Map of node name to private IP"
  value       = { for k, inst in aws_instance.nodes : k => inst.private_ip }
}
