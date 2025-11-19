terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.candidate_id}-sentiment-alarms"

  tags = {
    Name        = "${var.candidate_id}-cloudwatch-alarms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "sentiment_app" {
  dashboard_name = "${var.candidate_id}-sentiment-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["${var.cloudwatch_namespace}", "sentiment.analysis.total", { stat = "Sum", label = "Total Analyses" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Sentiment Analysis Requests"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["${var.cloudwatch_namespace}", "sentiment.bedrock.duration", { stat = "Average", label = "Avg Response Time" }],
            ["...", { stat = "Maximum", label = "Max Response Time" }],
            ["...", { stat = "Minimum", label = "Min Response Time" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "AWS Bedrock API Response Time (ms)"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["${var.cloudwatch_namespace}", "sentiment.confidence.score", { stat = "Average", label = "Avg Confidence" }],
            ["...", { stat = "Minimum", label = "Min Confidence" }],
            ["...", { stat = "Maximum", label = "Max Confidence" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Confidence Score Distribution"
          yAxis = {
            left = {
              min = 0
              max = 1
            }
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 6
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["${var.cloudwatch_namespace}", "sentiment.companies.detected", { stat = "Average", label = "Companies Detected" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Companies Detected (Gauge)"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 6
      }
    ]
  })
}

# CloudWatch Alarm - High API Response Time
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "${var.candidate_id}-high-bedrock-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "sentiment.bedrock.duration"
  namespace           = var.cloudwatch_namespace
  period              = 60
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "Triggers when average AWS Bedrock API response time exceeds ${var.response_time_threshold}ms"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alarms.arn]

  tags = {
    Name        = "${var.candidate_id}-high-response-time-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Alarm - Low Confidence Scores
resource "aws_cloudwatch_metric_alarm" "low_confidence" {
  alarm_name          = "${var.candidate_id}-low-confidence-scores"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "sentiment.confidence.score"
  namespace           = var.cloudwatch_namespace
  period              = 300
  statistic           = "Average"
  threshold           = var.confidence_threshold
  alarm_description   = "Triggers when average confidence score falls below ${var.confidence_threshold}"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alarms.arn]

  tags = {
    Name        = "${var.candidate_id}-low-confidence-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
