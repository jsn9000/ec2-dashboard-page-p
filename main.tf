# EC2 Dashboard S3 Hosting Terraform Module
# This module creates an S3 bucket with network-restricted access for hosting EC2 dashboard

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Data source to get current AWS region
data "aws_region" "current" {}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get EC2 instances
data "aws_instances" "all" {}

# Data source to get detailed EC2 instance information
data "aws_instance" "details" {
  for_each    = toset(data.aws_instances.all.ids)
  instance_id = each.value
}

# S3 Bucket - Use existing bucket
data "aws_s3_bucket" "dashboard_bucket" {
  bucket = var.bucket_name
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "dashboard_bucket_versioning" {
  bucket = data.aws_s3_bucket.dashboard_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dashboard_bucket_encryption" {
  bucket = data.aws_s3_bucket.dashboard_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "dashboard_bucket_pab" {
  bucket = data.aws_s3_bucket.dashboard_bucket.id

  block_public_acls       = true
  block_public_policy     = false  # Allow bucket policy for network restrictions
  ignore_public_acls      = true
  restrict_public_buckets = false  # Allow restricted public access via policy
}

# S3 Bucket Policy for Network Restriction
resource "aws_s3_bucket_policy" "dashboard_bucket_policy" {
  bucket = data.aws_s3_bucket.dashboard_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.dashboard_bucket_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RestrictToInternalNetwork"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${data.aws_s3_bucket.dashboard_bucket.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_cidr_blocks
          }
        }
      }
    ]
  })
}

# Process EC2 instance data
locals {
  # Transform EC2 instance data into a structured format
  instances_data = [
    for instance_id, instance in data.aws_instance.details : {
      id           = instance.id
      name         = try(instance.tags["Name"], "")
      type         = instance.instance_type
      status       = instance.instance_state
      private_ip   = instance.private_ip
      public_ip    = instance.public_ip
      az           = instance.availability_zone
      launch_time  = instance.launch_time
      launch_date  = formatdate("YYYY-MM-DD", instance.launch_time)
    }
  ]

  # Sort instances by launch time (oldest first)
  sorted_instances = [
    for launch_time in sort([for i in local.instances_data : i.launch_time]) : [
      for instance in local.instances_data : instance if instance.launch_time == launch_time
    ][0]
  ]

  # Generate JavaScript array for the HTML
  instances_js = jsonencode([
    for instance in local.sorted_instances : {
      id     = instance.id
      name   = instance.name
      type   = instance.type
      status = instance.status
      ip     = instance.private_ip
      az     = instance.az
      launch = instance.launch_date
    }
  ])

  # Calculate summary statistics
  total_instances   = length(local.instances_data)
  running_instances = length([for i in local.instances_data : i if i.status == "running"])
  stopped_instances = length([for i in local.instances_data : i if i.status == "stopped"])
  unique_azs       = length(distinct([for i in local.instances_data : i.az]))

  # Generate the complete HTML content with live data
  html_content = templatefile("${path.module}/dashboard.html.tpl", {
    dashboard_title   = var.dashboard_title
    bucket_name      = var.bucket_name
    region           = data.aws_region.current.name
    instances_js     = local.instances_js
    total_instances  = local.total_instances
    running_instances = local.running_instances
    stopped_instances = local.stopped_instances
    unique_azs       = local.unique_azs
    last_updated     = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  })
}

# S3 Object for HTML Dashboard
resource "aws_s3_object" "dashboard_html" {
  bucket       = data.aws_s3_bucket.dashboard_bucket.id
  key          = "index.html"
  content      = local.html_content
  content_type = "text/html"
  etag         = md5(local.html_content)
  tags         = var.tags
}

# S3 Object for Analysis Summary (placeholder)
resource "aws_s3_object" "analysis_md" {
  bucket       = data.aws_s3_bucket.dashboard_bucket.id
  key          = "analysis.md"
  content      = "# EC2 Analysis Summary\n\nThis file should be updated with your EC2 analysis data."
  content_type = "text/markdown"
  tags         = var.tags
}
