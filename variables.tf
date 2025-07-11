# Variables for EC2 Dashboard S3 Hosting Module

variable "bucket_name" {
  description = "Name of the S3 bucket to create for hosting the EC2 dashboard"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, contain only letters, numbers, and hyphens, and not start or end with a hyphen."
  }
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the dashboard"
  type        = list(string)
  default = [
    "10.240.0.0/16",    # Primary EC2 network
    "10.230.10.5/32",   # Specific host access
    "10.255.0.0/21",    # Management network
    "10.93.0.0/16",     # Corporate network 1
    "10.94.0.0/16",     # Corporate network 2
    "10.105.0.0/16"     # Corporate network 3
  ]
}

variable "dashboard_title" {
  description = "Title for the EC2 dashboard"
  type        = string
  default     = "EC2 Instances Overview"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "EC2Dashboard"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
