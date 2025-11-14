terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "pgr301-terraform-state"
    key    = "infra-s3/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for analysis results
resource "aws_s3_bucket" "analysis_data" {
  bucket = var.bucket_name

  tags = {
    Name        = "AiAlpha Analysis Data"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "analysis_data" {
  bucket = aws_s3_bucket.analysis_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle configuration for temporary files
resource "aws_s3_bucket_lifecycle_configuration" "analysis_data" {
  bucket = aws_s3_bucket.analysis_data.id

  rule {
    id     = "temporary-files-lifecycle"
    status = "Enabled"

    filter {
      prefix = var.temporary_prefix
    }

    # Transition to cheaper storage class after a period
    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }

    # Delete files after expiration period
    expiration {
      days = var.expiration_days
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Optional: Rule for cleaning up old versions
  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "analysis_data" {
  bucket = aws_s3_bucket.analysis_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "analysis_data" {
  bucket = aws_s3_bucket.analysis_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
