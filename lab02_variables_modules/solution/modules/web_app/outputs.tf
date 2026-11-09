output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.server.id
}

output "private_ip" {
  description = "Private IP of the created EC2 instance"
  value       = aws_instance.server.private_ip
}
