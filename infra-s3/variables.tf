variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for analysis data. Format: kandidat-<number>-data"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "temporary_prefix" {
  description = "Prefix/folder for temporary files that should be automatically deleted"
  type        = string
  default     = "midlertidig/"
}

variable "transition_to_glacier_days" {
  description = "Number of days before transitioning temporary files to Glacier storage"
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Number of days before deleting temporary files"
  type        = number
  default     = 90
}
