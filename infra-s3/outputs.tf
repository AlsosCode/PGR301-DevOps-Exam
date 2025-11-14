output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.analysis_data.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.analysis_data.arn
}

output "bucket_region" {
  description = "AWS region where the bucket was created"
  value       = aws_s3_bucket.analysis_data.region
}

output "lifecycle_policy_id" {
  description = "ID of the temporary files lifecycle policy"
  value       = aws_s3_bucket_lifecycle_configuration.analysis_data.id
}

output "temporary_prefix" {
  description = "Prefix for temporary files with lifecycle management"
  value       = var.temporary_prefix
}

output "expiration_days" {
  description = "Number of days before temporary files are deleted"
  value       = var.expiration_days
}
