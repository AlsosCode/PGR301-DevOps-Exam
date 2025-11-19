output "dashboard_name" {
  description = "Name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.sentiment_app.dashboard_name
}

output "dashboard_url" {
  description = "URL to the CloudWatch Dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.sentiment_app.dashboard_name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.cloudwatch_alarms.arn
}

output "high_response_time_alarm" {
  description = "Name of the high response time alarm"
  value       = aws_cloudwatch_metric_alarm.high_response_time.alarm_name
}

output "low_confidence_alarm" {
  description = "Name of the low confidence alarm"
  value       = aws_cloudwatch_metric_alarm.low_confidence.alarm_name
}

output "alarm_email" {
  description = "Email address for alarm notifications"
  value       = var.alarm_email
  sensitive   = true
}
