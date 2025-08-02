# EC2 Dashboard S3 Hosting Terraform Module

This Terraform module automatically creates a secure, network-restricted S3-hosted dashboard for your EC2 instances using an existing S3 bucket. The dashboard displays live EC2 instance data with interactive charts and detailed tables, sorted chronologically by launch date.

## Features

- 🔄 **Live Data**: Automatically fetches current EC2 instance data during Terraform runs
- 📊 **Interactive Dashboard**: Professional charts showing status, types, availability zones, and timeline
- 🔒 **Network Security**: Restricts access to specified CIDR blocks only
- 📅 **Chronological Sorting**: Instances sorted by launch date (oldest first)
- 🏷️ **Auto-Updates**: Dashboard updates every time Terraform is run
- 🎨 **Professional UI**: Clean, responsive design with AWS-themed styling

## Quick Start

### 1. Basic Usage

```hcl
module "ec2_dashboard" {
  source = "./path/to/this/module"
  
  bucket_name = "my-ec2-dashboard-bucket"
}
```

### 2. Custom Configuration

```hcl
module "ec2_dashboard" {
  source = "./path/to/this/module"
  
  bucket_name     = "company-ec2-dashboard"
  dashboard_title = "EC2 Instances Details"
  
```python?code_reference&code_event_index=2
import re

text = """allowed_cidr_blocks = [
    "10.x.x.x/16",     # Primary EC2 network
    "10.x.x.x/32",    # Specific host access
    "10.x.x.x/21",     # Management network
    "10.x.x.x/16",      # Corporate network 1
    "10.x.x.x/16",      # Corporate network 2
    "10.x.x.x/16",     # Corporate network 3
    "192.168.1.0/24"     # Additional network
  ]"""

def replace_ips_with_placeholders(text):
    lines = text.strip().split('\n')
    updated_lines = []
    
    for line in lines:
        if "10." in line and "x.x.x" not in line:
            # Match 10. followed by any digits and dots, up to the slash
            line = re.sub(r'10\.(\d+\.)?\d+\.\d+\.\d+', r'10.x.x.x', line)
            # Handle the specific case of "10./16"
            line = line.replace('10./16', '10.x.x.x/16')
        
        updated_lines.append(line)
        
    return '\n'.join(updated_lines)

updated_text = replace_ips_with_placeholders(text)
print(updated_text)
```

```text?code_stdout&code_event_index=2
allowed_cidr_blocks = [
    "10.x.x.x/16",     # Primary EC2 network
    "10.x.x.x/32",    # Specific host access
    "10.x.x.x/21",     # Management network
    "10.x.x.x/16",      # Corporate network 1
    "10.x.x.x/16",      # Corporate network 2
    "10.x.x.x/16",     # Corporate network 3
    "192.168.1.0/24"     # Additional network
  ]

```

Based on the format you provided, here is the updated list with the IP addresses changed to the `10.x.x.x` placeholder. The non-`10.x.x.x` address remains as it was in your example.

```
allowed_cidr_blocks = [
    "10.x.x.x/16",     # Primary EC2 network
    "10.x.x.x/32",    # Specific host access
    "10.x.x.x/21",     # Management network
    "10.x.x.x/16",      # Corporate network 1
    "10.x.x.x/16",      # Corporate network 2
    "10.x.x.x/16",     # Corporate network 3
    "192.168.1.0/24"     # Additional network
  ]
```
  
  tags = {
    Project     = "Infrastructure"
    Environment = "Production"
    Owner       = "DevOps Team"
  }
}
```

## Prerequisites

- Terraform >= 1.0
- AWS Provider >= 5.0
- AWS credentials configured with EC2 read permissions
- **Existing S3 bucket** - This module uses an existing bucket rather than creating a new one
- S3 permissions for bucket policy and object management

## Required AWS Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "s3:CreateBucket",
        "s3:PutObject",
        "s3:PutBucketPolicy",
        "s3:PutBucketVersioning",
        "s3:PutBucketEncryption",
        "s3:PutPublicAccessBlock"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage Steps

### 1. Copy Example Configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Configuration

```bash
# Edit terraform.tfvars with your bucket name and settings
bucket_name = "your-unique-bucket-name"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access Dashboard

The module outputs the dashboard URL:

```bash
# Direct access from allowed networks
terraform output dashboard_url

# Generate pre-signed URL for temporary access
terraform output presigned_url_command
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `bucket_name` | S3 bucket name for hosting dashboard | `string` | n/a | yes |
| `allowed_cidr_blocks` | CIDR blocks allowed to access dashboard | `list(string)` | See defaults | no |
| `dashboard_title` | Title displayed on dashboard | `string` | "EC2 Instances Overview" | no |
| `tags` | Tags applied to all resources | `map(string)` | See defaults | no |

### Default Allowed Networks

The module includes these networks by default:
- `10.240.0.0/16` - Primary EC2 network
- `10.230.10.5/32` - Specific host access
- `10.255.0.0/21` - Management network
- `10.93.0.0/16` - Corporate network 1
- `10.94.0.0/16` - Corporate network 2
- `10.105.0.0/16` - Corporate network 3

## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | Name of created S3 bucket |
| `bucket_arn` | ARN of created S3 bucket |
| `dashboard_url` | Direct URL to dashboard |
| `presigned_url_command` | Command to generate pre-signed URLs |
| `allowed_networks` | Configured CIDR blocks |
| `instance_count` | Total number of EC2 instances |
| `running_instances` | Number of running instances |
| `stopped_instances` | Number of stopped instances |
| `availability_zones` | Number of unique AZs |

## Dashboard Features

### Summary Cards
- Total instances count
- Running instances count
- Stopped instances count
- Availability zones count

### Interactive Charts
- **Status Distribution**: Doughnut chart showing running vs stopped
- **Instance Types**: Bar chart of instance type distribution
- **Availability Zones**: Pie chart of AZ distribution
- **Launch Timeline**: Line chart showing instances launched over time

### Detailed Table
- Instance ID, Name, Type, Status
- Private IP, Availability Zone, Launch Date
- Sortable and searchable
- Chronologically ordered (oldest first)

## Security Features

- **Public Access Blocked**: All public access explicitly denied
- **Network Restriction**: Access limited to specified CIDR blocks
- **Encryption**: Server-side encryption enabled
- **Versioning**: S3 versioning enabled for change tracking
- **No Public URLs**: Dashboard never accessible from internet

## Access Methods

### From Allowed Networks
```bash
# Direct access (permanent)
https://s3.region.amazonaws.com/bucket-name/index.html
```

### Pre-signed URLs
```bash
# Generate 24-hour URL
aws s3 presign s3://bucket-name/index.html --expires-in 86400

# Generate 7-day URL (maximum)
aws s3 presign s3://bucket-name/index.html --expires-in 604800
```

### AWS Console
1. Navigate to S3 Console
2. Open your bucket
3. Click on `index.html`
4. Click "Open"

## Updating the Dashboard

The dashboard automatically updates with fresh EC2 data every time you run:

```bash
terraform apply
```

This ensures your dashboard always shows current instance information.

## Troubleshooting

### Common Issues and Solutions

#### Access Denied Errors
**Problem**: Getting "Access Denied" when trying to access the dashboard URL.

**Solutions**:
1. **Check Network Access**: Verify your IP address is within the allowed CIDR blocks
   ```bash
   # Check your current IP
   curl -s https://ipinfo.io/ip
   ```
2. **Public Access Block Settings**: Ensure the bucket's public access block allows the policy
   - `block_public_policy` should be `false`
   - `restrict_public_buckets` should be `false`
3. **Bucket Policy**: Verify the bucket policy is correctly applied and includes your network
4. **AWS Credentials**: Check that your AWS credentials have the required S3 permissions

#### Terraform Plan/Apply Errors

**Problem**: `sort()` function errors or invalid function arguments.

**Solution**: This was a common issue we resolved. The module now uses proper sorting logic:
```hcl
# Fixed: Proper sorting of instances by launch time
sorted_instances = [
  for launch_time in sort([for i in local.instances_data : i.launch_time]) : [
    for instance in local.instances_data : instance if instance.launch_time == launch_time
  ][0]
]
```

**Problem**: `formatdate()` function errors with "invalid date format verb".

**Solution**: Use proper Terraform date format strings:
```hcl
# Fixed: Removed invalid "UTC" format verb
last_updated = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
```

**Problem**: "Reference to undeclared resource" errors.

**Solution**: Ensure all references use the correct resource type (data source vs resource):
```hcl
# Correct: Using data source reference
bucket = data.aws_s3_bucket.dashboard_bucket.id
```

#### Bucket Configuration Issues

**Problem**: Module tries to create a bucket that already exists.

**Solution**: The module is designed to use existing buckets. Ensure:
1. The bucket name in `terraform.tfvars` matches your existing bucket
2. You have permissions to modify the existing bucket
3. The bucket is in the same region as your Terraform provider

#### No Instance Data Displayed

**Problem**: Dashboard shows no EC2 instances or empty data.

**Solutions**:
1. **EC2 Permissions**: Verify AWS credentials have `ec2:DescribeInstances` permission
2. **Region Check**: Ensure you're looking in the correct AWS region
3. **Instance Existence**: Confirm EC2 instances actually exist in the target region
4. **Terraform Logs**: Check `terraform plan` output for data source errors

#### Network Access Issues

**Problem**: Can't access dashboard from expected network.

**Solutions**:
1. **CIDR Block Verification**: Double-check your network's CIDR block is correctly specified
2. **NAT/Proxy Issues**: If behind NAT or proxy, ensure the public IP is included
3. **VPN Considerations**: VPN connections may change your apparent source IP
4. **Corporate Firewall**: Check if corporate firewalls block S3 access

### Best Practices Learned

1. **Always Use Existing Buckets**: This module works best with pre-existing S3 buckets
2. **Test Network Access**: Verify CIDR blocks before deployment
3. **Monitor Terraform State**: Keep track of which resources are managed vs referenced
4. **Use Proper Data Types**: Ensure data sources and resources are correctly referenced
5. **Validate Permissions**: Test AWS permissions before running Terraform
6. **Save Plans**: Use `terraform plan -out=tfplan` for consistent deployments

### Debugging Commands

```bash
# Check Terraform plan for errors
terraform plan

# Validate Terraform configuration
terraform validate

# Check current AWS identity
aws sts get-caller-identity

# Test S3 bucket access
aws s3 ls s3://your-bucket-name

# Check EC2 instances in current region
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'

# Generate pre-signed URL for testing
aws s3 presign s3://your-bucket-name/index.html --expires-in 3600
```

## File Structure

```
.
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── dashboard.html.tpl         # HTML template with live data
├── terraform.tfvars.example   # Example variables file
├── README.md                  # This documentation
└── bucket-policy.json         # Generated bucket policy (after apply)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## License

This module is released under the MIT License.
