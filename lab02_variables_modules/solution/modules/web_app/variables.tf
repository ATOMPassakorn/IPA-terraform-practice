variable "instance_type" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.micro"
}

variable "server_name" {
  type        = string
  description = "Name prefix for the server"
}

variable "volume_config" {
  type = object({
    size_gb   = number
    encrypted = bool
  })
  description = "Root volume configuration"

  validation {
    condition     = var.volume_config.size_gb >= 10 && var.volume_config.size_gb <= 100
    error_message = "Volume size must be between 10 and 100 GB."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}
