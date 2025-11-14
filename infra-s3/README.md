# Infrastructure - S3 Storage for Analysis Data

This directory contains Terraform configuration for provisioning the S3 bucket used to store AiAlpha sentiment analysis results.

## Overview

The infrastructure creates:
- **S3 Bucket**: Storage for analysis results with versioning enabled
- **Lifecycle Policy**: Automatic management of temporary files
- **Security**: Encryption at rest and public access blocking
- **Cost Optimization**: Automatic transition to Glacier and deletion of temporary data

## Architecture

```
s3://kandidat-XXX-data/
├── midlertidig/          # Temporary files (auto-deleted after 90 days)
│   ├── [transitions to Glacier after 30 days]
│   └── [deleted after 90 days]
└── permanent/            # Permanent storage (no lifecycle rules)
```

## Lifecycle Policy

Files stored under the `midlertidig/` prefix follow this lifecycle:

1. **Day 0-29**: Standard S3 storage
2. **Day 30-89**: Automatically moved to Glacier (cheaper storage)
3. **Day 90+**: Automatically deleted

Files **outside** the `midlertidig/` prefix are stored permanently with no automatic deletion.

## Prerequisites

1. **AWS Account** with appropriate credentials
2. **Terraform** >= 1.5 installed
3. **S3 Backend Bucket**: The `pgr301-terraform-state` bucket must exist in `eu-west-1`
4. **AWS Credentials** configured (via environment variables or AWS CLI)

## Configuration

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set your candidate number:
   ```hcl
   bucket_name = "kandidat-<YOUR-NUMBER>-data"
   ```

3. Optional: Customize lifecycle settings:
   - `transition_to_glacier_days` - Days before moving to Glacier (default: 30)
   - `expiration_days` - Days before deletion (default: 90)

## Usage

### Initialize Terraform
```bash
terraform init
```

### Validate Configuration
```bash
terraform validate
terraform fmt -check
```

### Plan Changes
```bash
terraform plan
```

### Apply Infrastructure
```bash
terraform apply
```

### View Outputs
```bash
terraform output
```

## Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `bucket_name` | S3 bucket name (kandidat-XXX-data) | - | Yes |
| `aws_region` | AWS region | eu-west-1 | No |
| `environment` | Environment tag | production | No |
| `temporary_prefix` | Prefix for temporary files | midlertidig/ | No |
| `transition_to_glacier_days` | Days before Glacier transition | 30 | No |
| `expiration_days` | Days before deletion | 90 | No |

## Outputs

| Output | Description |
|--------|-------------|
| `bucket_name` | Name of the created S3 bucket |
| `bucket_arn` | ARN of the S3 bucket |
| `bucket_region` | AWS region of the bucket |
| `lifecycle_policy_id` | ID of the lifecycle policy |
| `temporary_prefix` | Prefix for temporary files |
| `expiration_days` | Expiration period in days |

## Security Features

- **Encryption**: AES256 server-side encryption enabled by default
- **Versioning**: Enabled to protect against accidental deletion
- **Public Access**: Completely blocked at bucket level
- **Old Versions**: Automatically cleaned up after 90 days

## CI/CD Integration

This infrastructure is automatically managed via GitHub Actions:
- **Pull Requests**: Runs `terraform fmt`, `validate`, and `plan`
- **Main Branch**: Runs `terraform apply` on merge

See `.github/workflows/terraform-s3.yml` for workflow details.

## Cost Optimization

The lifecycle policy helps minimize storage costs:
- Temporary files transition to Glacier (90% cheaper than S3 Standard)
- Automatic deletion prevents accumulation of unused data
- Versioning cleanup removes old object versions

## Troubleshooting

### Backend Initialization Error
If you get an error about the backend bucket:
```
Error: Failed to get existing workspaces: S3 bucket does not exist
```

Ensure the `pgr301-terraform-state` bucket exists in `eu-west-1`.

### Permission Errors
Ensure your AWS credentials have the following permissions:
- `s3:CreateBucket`
- `s3:PutBucketLifecycleConfiguration`
- `s3:PutBucketVersioning`
- `s3:PutEncryptionConfiguration`
- `s3:PutBucketPublicAccessBlock`

## Manual Bucket Creation (Fallback)

If Terraform fails, you can create the bucket manually:

1. Go to AWS Console → S3
2. Create bucket: `kandidat-<YOUR-NUMBER>-data`
3. Region: `eu-west-1`
4. Enable versioning
5. Enable default encryption (AES256)
6. Block all public access
7. Add lifecycle rule for `midlertidig/` prefix

## Resources

- [Terraform AWS S3 Bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [S3 Lifecycle Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)
- [AWS S3 Storage Classes](https://aws.amazon.com/s3/storage-classes/)
