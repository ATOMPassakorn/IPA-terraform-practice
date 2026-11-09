output "cluster_node_ids" {
  description = "Map of cluster node names to EC2 instance IDs"
  value       = module.app_cluster.node_ids
}

output "summary_report" {
  description = "Formatted summary message of cluster deployment"
  value       = format("Cluster [%s] deployed with %d nodes", local.cluster_prefix, length(keys(local.cluster_nodes)))
}

output "public_ports_allowed" {
  description = "List of allowed ingress ports extracted using for expression"
  value       = [for p in var.ingress_ports : p.port]
}

# Answers to self-check questions:
# Q1: terraform state rm aws_security_group.cluster_sg
# Q2: terraform apply -replace='module.app_cluster.aws_instance.nodes["web"]'
