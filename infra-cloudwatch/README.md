# CloudWatch Observability Infrastructure

Terraform infrastructure for monitoring the Sentiment Analysis application with CloudWatch.

## Overview

This Terraform configuration creates:
- **CloudWatch Dashboard**: Visualizes application metrics
- **CloudWatch Alarms**: Monitors critical thresholds
- **SNS Topic & Subscription**: Email notifications for alarms

## Prerequisites

1. AWS credentials configured
2. Sentiment Docker application deployed and running
3. Application generating metrics to CloudWatch namespace `kandidat-6`

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your email:
```hcl
alarm_email = "your-email@example.com"
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 3. Confirm SNS Subscription

After deployment, check your email and click the confirmation link to subscribe to alarm notifications.

## Dashboard Widgets

The CloudWatch Dashboard includes four widgets:

### 1. Sentiment Analysis Requests (Counter)
- **Metric**: `sentiment.analysis.total`
- **Type**: Line graph showing total analysis requests over time
- **Purpose**: Track application usage and request volume

### 2. AWS Bedrock API Response Time (Timer)
- **Metric**: `sentiment.bedrock.duration`
- **Type**: Line graph with Average, Max, and Min response times
- **Purpose**: Monitor API performance and detect latency issues
- **Unit**: Milliseconds

### 3. Confidence Score Distribution (DistributionSummary)
- **Metric**: `sentiment.confidence.score`
- **Type**: Line graph showing confidence score statistics
- **Purpose**: Analyze quality of sentiment analysis results
- **Range**: 0.0 to 1.0

### 4. Companies Detected (Gauge)
- **Metric**: `sentiment.companies.detected`
- **Type**: Number/line graph showing current count
- **Purpose**: Track number of companies identified in last analysis
- **Note**: Value fluctuates as new analyses are processed

## CloudWatch Alarms

### 1. High Response Time Alarm
- **Condition**: Average response time > 5000ms for 2 evaluation periods
- **Period**: 60 seconds
- **Action**: Sends email via SNS when triggered
- **Purpose**: Detect performance degradation in Bedrock API calls

### 2. Low Confidence Score Alarm
- **Condition**: Average confidence < 0.5 for 2 evaluation periods
- **Period**: 300 seconds (5 minutes)
- **Action**: Sends email via SNS when triggered
- **Purpose**: Alert when sentiment analysis quality degrades

## Customization

### Adjusting Alarm Thresholds

Edit `terraform.tfvars`:

```hcl
# Increase response time threshold to 10 seconds
response_time_threshold = 10000

# Lower confidence threshold to 30%
confidence_threshold = 0.3
```

Then reapply:
```bash
terraform apply
```

### Adding More Widgets

Edit `main.tf` and add widgets to the `dashboard_body` JSON structure. See [AWS Dashboard Body Structure](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html).

## Testing Alarms

### Trigger High Response Time Alarm

The response time alarm will trigger naturally if Bedrock API slows down. To test:
1. Make multiple API requests
2. Wait for metrics to aggregate
3. Check alarm state in CloudWatch Console

### Trigger Low Confidence Alarm

Send ambiguous text that generates low confidence scores:
```bash
curl -X POST http://localhost:8080/api/analyze \
  -H "Content-Type: application/json" \
  -d '{"requestId": "test-1", "text": "maybe possibly could potentially"}'
```

## Outputs

After applying, Terraform will output:

- **dashboard_name**: Name of the created dashboard
- **dashboard_url**: Direct link to view the dashboard
- **sns_topic_arn**: ARN for the SNS notification topic
- **high_response_time_alarm**: Name of the latency alarm
- **low_confidence_alarm**: Name of the confidence alarm

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: This will delete the dashboard, alarms, and SNS topic. Metrics data in CloudWatch will be retained based on CloudWatch's retention policy.

## Architecture

```
Application (Docker)
    ↓ (Micrometer)
CloudWatch Metrics (kandidat-6 namespace)
    ↓
CloudWatch Dashboard (Visualization)
    ↓
CloudWatch Alarms (Threshold monitoring)
    ↓
SNS Topic
    ↓
Email Notification
```

## Troubleshooting

### No metrics visible in dashboard

1. Verify application is running and processing requests
2. Check that `MetricsConfig.java` namespace matches `kandidat-6`
3. Wait 5-10 minutes for metrics to propagate
4. Check CloudWatch Metrics console for the `kandidat-6` namespace

### Alarm not triggering

1. Verify metrics are being collected
2. Check alarm threshold values are appropriate
3. Ensure 2 evaluation periods have passed
4. Review alarm history in CloudWatch Console

### Email notifications not received

1. Check spam folder
2. Verify SNS subscription is confirmed (check email for confirmation link)
3. Check SNS topic subscription status in AWS Console

## Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example configuration
- `.gitignore` - Excludes sensitive files from git

## Related Documentation

- [Task 4 Requirements](../README_OPPGAVER.md#oppgave-4)
- [Answer Documentation](../README_SVAR.md#oppgave-4)
- [Metrics Implementation](../sentiment-docker/src/main/java/com/aialpha/sentiment/metrics/)
