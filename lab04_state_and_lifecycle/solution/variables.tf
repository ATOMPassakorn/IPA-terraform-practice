variable "instance_name" {
  type        = string
  description = "Name identifier for the server"
  default     = "default-server"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}
