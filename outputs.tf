# Outputs for EC2 Dashboard S3 Hosting Module

output "bucket_name" {
  description = "Name of the existing S3 bucket"
  value       = data.aws_s3_bucket.dashboard_bucket.id
}

output "bucket_arn" {
  description = "ARN of the existing S3 bucket"
  value       = data.aws_s3_bucket.dashboard_bucket.arn
}

output "dashboard_url" {
  description = "Direct S3 URL for the dashboard (accessible from allowed networks)"
  value       = "https://s3.${data.aws_region.current.name}.amazonaws.com/${data.aws_s3_bucket.dashboard_bucket.id}/index.html"
}

output "presigned_url_command" {
  description = "AWS CLI command to generate a pre-signed URL"
  value       = "aws s3 presign s3://${data.aws_s3_bucket.dashboard_bucket.id}/index.html --expires-in 86400"
}

output "allowed_networks" {
  description = "CIDR blocks allowed to access the dashboard"
  value       = var.allowed_cidr_blocks
}

output "instance_count" {
  description = "Number of EC2 instances found and included in the dashboard"
  value       = local.total_instances
}

output "running_instances" {
  description = "Number of running EC2 instances"
  value       = local.running_instances
}

output "stopped_instances" {
  description = "Number of stopped EC2 instances"
  value       = local.stopped_instances
}

output "availability_zones" {
  description = "Number of unique availability zones"
  value       = local.unique_azs
}
