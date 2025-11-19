variable "aws_region" {
  description = "AWS region for CloudWatch resources"
  type        = string
  default     = "eu-west-1"
}

variable "candidate_id" {
  description = "Candidate identifier for resource naming"
  type        = string
  default     = "kandidat-6"
}

variable "cloudwatch_namespace" {
  description = "CloudWatch namespace - MUST match the namespace in MetricsConfig.java"
  type        = string
  default     = "kandidat-6"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  # Set this in terraform.tfvars or via -var flag
}

variable "response_time_threshold" {
  description = "Threshold for high response time alarm in milliseconds"
  type        = number
  default     = 5000 # 5 seconds
}

variable "confidence_threshold" {
  description = "Threshold for low confidence score alarm (0.0 to 1.0)"
  type        = number
  default     = 0.5 # Alert if average confidence drops below 50%
}
