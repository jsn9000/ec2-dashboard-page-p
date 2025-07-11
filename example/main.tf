# Example usage of the EC2 Dashboard S3 Hosting Module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Use the EC2 Dashboard module
module "ec2_dashboard" {
  source = "../"  # Path to the module directory
  
  # Required: Unique S3 bucket name
  bucket_name = "my-company-ec2-dashboard-2025"
  
  # Optional: Custom dashboard title
  dashboard_title = "Production EC2 Infrastructure Dashboard"
  
  # Optional: Override default allowed networks
  allowed_cidr_blocks = [
    "10.240.0.0/16",    # Primary EC2 network
    "10.230.10.5/32",   # Specific host access
    "10.255.0.0/21",    # Management network
    "10.93.0.0/16",     # Corporate network 1
    "10.94.0.0/16",     # Corporate network 2
    "10.105.0.0/16",    # Corporate network 3
    "192.168.1.0/24"    # Office network
  ]
  
  # Optional: Custom tags
  tags = {
    Project     = "Infrastructure"
    Environment = "Production"
    Owner       = "DevOps Team"
    ManagedBy   = "Terraform"
    CostCenter  = "IT-Operations"
  }
}

# Output the dashboard information
output "dashboard_info" {
  description = "EC2 Dashboard access information"
  value = {
    bucket_name    = module.ec2_dashboard.bucket_name
    dashboard_url  = module.ec2_dashboard.dashboard_url
    instance_count = module.ec2_dashboard.instance_count
    running_count  = module.ec2_dashboard.running_instances
    stopped_count  = module.ec2_dashboard.stopped_instances
  }
}

output "access_commands" {
  description = "Commands to access the dashboard"
  value = {
    presigned_url = module.ec2_dashboard.presigned_url_command
    direct_url    = "Open this URL from an allowed network: ${module.ec2_dashboard.dashboard_url}"
  }
}
