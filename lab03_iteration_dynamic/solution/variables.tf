variable "environment" {
  type        = string
  description = "Target deployment environment"
  default     = "dev"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "web_servers" {
  type = map(object({
    instance_type = string
    is_public     = bool
  }))
  description = "Map of server configurations"
  default = {
    "frontend" = { instance_type = "t3.micro", is_public = true }
    "backend"  = { instance_type = "t3.small", is_public = false }
  }
}

variable "firewall_rules" {
  type = list(object({
    port        = number
    description = string
    protocol    = string
  }))
  description = "List of ingress firewall rules"
  default = [
    { port = 80, description = "HTTP", protocol = "tcp" },
    { port = 443, description = "HTTPS", protocol = "tcp" },
    { port = 22, description = "SSH", protocol = "tcp" }
  ]
}
