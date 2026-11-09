variable "cluster_name" {
  type        = string
  description = "Name identifier for the cluster"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "node_specs" {
  type = map(object({
    instance_type = string
    disk_gb       = number
  }))
  description = "Specifications for cluster nodes"

  validation {
    condition     = alltrue([for k, v in var.node_specs : v.disk_gb >= 10 && v.disk_gb <= 100])
    error_message = "All node disk sizes must be between 10 and 100 GB."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
