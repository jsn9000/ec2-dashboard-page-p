# Prompt for Similar AWS Dashboard Projects

Use this prompt when you need to create similar AWS resource dashboards with Terraform. This template is based on lessons learned from creating an EC2 dashboard with S3 hosting.

## Project Prompt Template

```
Create a Terraform module that generates a secure, network-restricted dashboard for [AWS_SERVICE] resources hosted on S3. The dashboard should:

**Core Requirements:**
1. Use an EXISTING S3 bucket (do not create a new bucket)
2. Fetch live [AWS_SERVICE] data using Terraform data sources
3. Generate an interactive HTML dashboard with charts and tables
4. Restrict access to specific CIDR blocks only
5. Sort resources chronologically by creation/launch date
6. Auto-update dashboard content on each Terraform run

**Technical Specifications:**
- Use Terraform >= 1.0 with AWS Provider >= 5.0
- Implement proper error handling for Terraform functions
- Use data sources (not resources) for the S3 bucket reference
- Configure S3 public access blocks correctly for policy-based access
- Include comprehensive .gitignore for Terraform files

**Dashboard Features:**
- Summary cards showing key metrics
- Interactive charts (status, types, regions/AZs, timeline)
- Detailed sortable table with all resource information
- Professional AWS-themed styling
- Responsive design for mobile/desktop

**Security Requirements:**
- Network-restricted access via S3 bucket policy
- Server-side encryption enabled
- S3 versioning enabled
- No public internet access
- Support for pre-signed URLs for temporary access

**Common Issues to Avoid:**
1. SORTING ERRORS: Use proper Terraform sorting syntax:
   ```hcl
   sorted_resources = [
     for timestamp in sort([for r in local.resources_data : r.creation_time]) : [
       for resource in local.resources_data : resource if resource.creation_time == timestamp
     ][0]
   ]
   ```

2. DATE FORMAT ERRORS: Use valid Terraform date formats:
   ```hcl
   last_updated = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
   ```

3. RESOURCE REFERENCE ERRORS: Use data sources for existing resources:
   ```hcl
   data "aws_s3_bucket" "dashboard_bucket" {
     bucket = var.bucket_name
   }
   ```

4. ACCESS DENIED ISSUES: Configure public access blocks properly:
   ```hcl
   resource "aws_s3_bucket_public_access_block" "dashboard_bucket_pab" {
     bucket = data.aws_s3_bucket.dashboard_bucket.id
     block_public_acls       = true
     block_public_policy     = false  # Allow bucket policy
     ignore_public_acls      = true
     restrict_public_buckets = false  # Allow restricted access
   }
   ```

**File Structure to Create:**
- main.tf (main configuration with data sources and locals)
- variables.tf (input variables)
- outputs.tf (module outputs)
- dashboard.html.tpl (HTML template with embedded data)
- terraform.tfvars.example (example configuration)
- .gitignore (Terraform-specific gitignore)
- README.md (comprehensive documentation)

**Testing Checklist:**
1. Run `terraform validate` to check syntax
2. Run `terraform plan` to verify no errors
3. Test network access from allowed CIDR blocks
4. Verify dashboard displays live data correctly
5. Test pre-signed URL generation
6. Confirm security restrictions work

**Documentation Requirements:**
- Include troubleshooting section with common issues
- Provide debugging commands
- Document all variables and outputs
- Include security considerations
- Add examples for different use cases

Replace [AWS_SERVICE] with the specific service (e.g., RDS, Lambda, ECS, etc.)
```

## Service-Specific Examples

### For RDS Dashboard:
```
Create a Terraform module that generates a secure, network-restricted dashboard for RDS instances hosted on S3. Focus on database metrics like engine types, instance classes, storage, and backup status.
```

### For Lambda Dashboard:
```
Create a Terraform module that generates a secure, network-restricted dashboard for Lambda functions hosted on S3. Include runtime distributions, memory allocations, timeout settings, and last modified dates.
```

### For ECS Dashboard:
```
Create a Terraform module that generates a secure, network-restricted dashboard for ECS services and tasks hosted on S3. Show cluster distributions, service status, task definitions, and resource utilization.
```

## Key Lessons Learned

1. **Always use existing S3 buckets** - Avoid bucket creation conflicts
2. **Test Terraform functions carefully** - sort(), formatdate(), etc. have specific syntax requirements
3. **Configure S3 access blocks properly** - Balance security with functionality
4. **Use data sources for existing resources** - Don't mix resource creation with resource referencing
5. **Include comprehensive error handling** - Plan for common Terraform pitfalls
6. **Test network access thoroughly** - CIDR blocks and IP restrictions can be tricky
7. **Document troubleshooting extensively** - Future users will face similar issues

## MCP Servers Used in Original Project

The following MCP servers were valuable for this type of project:
- `awslabs.core-mcp-server` - AWS expert guidance and prompt understanding
- `awslabs.terraform-mcp-server` - Terraform-specific help and documentation
- `awslabs.aws-documentation-mcp-server` - AWS service documentation access
- `awslabs.cost-analysis-mcp-server` - Cost analysis and optimization guidance

Always start with the core MCP server for initial guidance and project understanding.
