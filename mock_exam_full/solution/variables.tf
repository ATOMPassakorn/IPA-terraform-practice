variable "environment" {
  type        = string
  description = "Target deployment environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  type        = string
  description = "Project name identifier"
  default     = "ipa-exam"
}

variable "admin_api_token" {
  type        = string
  description = "Secret administrator API token"
  sensitive   = true
  default     = "SecretToken123456"
}

variable "ingress_ports" {
  type = list(object({
    port        = number
    protocol    = string
    description = string
  }))
  description = "Allowed ingress firewall rules"
  default = [
    { port = 80, protocol = "tcp", description = "HTTP" },
    { port = 443, protocol = "tcp", description = "HTTPS" },
    { port = 8080, protocol = "tcp", description = "App Port" }
  ]
}
