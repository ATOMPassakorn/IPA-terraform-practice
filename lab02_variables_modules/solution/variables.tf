variable "aws_region" {
  type        = string
  description = "Target AWS Region"
  default     = "ap-southeast-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod."
  }
}

variable "admin_password" {
  type        = string
  description = "Administrator secret password"
  sensitive   = true
  default     = "SuperSecret123!"
}
