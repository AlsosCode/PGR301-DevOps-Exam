# PGR301 Exam 2025 - AiAlpha Sentiment Analysis Platform

A DevOps-focused implementation of a Big Tech sentiment analysis platform demonstrating Infrastructure as Code, CI/CD pipelines, containerization, and comprehensive observability.

**Course:** PGR301 DevOps i Skyen
**Candidate:** 6
**Date:** November 2025

![AWS](https://img.shields.io/badge/AWS-SAM%20%7C%20Lambda%20%7C%20S3-FF9900?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FBA?logo=terraform)
![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?logo=docker)
![Java](https://img.shields.io/badge/Java-21-ED8B00?logo=openjdk)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)
![CloudWatch](https://img.shields.io/badge/CloudWatch-Metrics-FF4F8B?logo=amazon-aws)

---

## 🚀 Quick Start

See **[README_SVAR.md](README_SVAR.md)** for complete implementation details and answers.

### Prerequisites
- AWS Account with configured credentials
- Docker installed
- Terraform 1.5+
- SAM CLI (for Lambda deployment)
- Java 21 and Maven (for Spring Boot app)

### Deployment

```bash
# 1. Deploy S3 infrastructure
cd infra-s3
terraform init
terraform apply -var="bucket_name=kandidat-6-data"

# 2. Deploy SAM application
cd sam-comprehend
sam build
sam deploy --guided

# 3. Build and run Docker container
cd sentiment-docker
docker build -t sentiment-docker .
docker run -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e S3_BUCKET_NAME=kandidat-6-data \
  sentiment-docker:latest

# 4. Deploy CloudWatch infrastructure
cd infra-cloudwatch
terraform init
terraform apply
```

---

## 🏗️ Architecture

### Components

**Infrastructure (Terraform)**
- **S3 Bucket** - Data storage with lifecycle policies
- **CloudWatch Dashboard** - Real-time metrics visualization
- **CloudWatch Alarms** - Automated alerting via SNS
- **SNS Topics** - Email notifications

**Serverless (AWS SAM)**
- **Lambda Function** - Python 3.11 sentiment analysis
- **API Gateway** - REST endpoint
- **AWS Comprehend** - Document-level sentiment

**Containerized Application (Docker)**
- **Spring Boot 3.3** - Java-based sentiment service
- **AWS Bedrock** - Company-level AI analysis
- **Micrometer** - CloudWatch metrics integration
- **Multi-stage builds** - Optimized image size

### CI/CD Pipelines

**GitHub Actions Workflows:**
1. `terraform-s3.yml` - Infrastructure validation and deployment
2. `sam-deploy.yml` - Lambda deployment with validation
3. `docker-build.yml` - Container build and Docker Hub push

### Observability

**Custom Metrics (Micrometer → CloudWatch):**
- **Counter** - Total sentiment analysis requests
- **Timer** - AWS Bedrock API response times
- **Gauge** - Companies detected per analysis
- **DistributionSummary** - Confidence score distribution

**Alarms:**
- High API response time (>5000ms)
- Low confidence scores (<50%)

---

## 🛠️ Technologies

### Infrastructure & Platform
- **AWS**: Lambda, S3, CloudWatch, SNS, Bedrock, Comprehend
- **Terraform**: Infrastructure as Code (IaC)
- **Docker**: Multi-stage containerization
- **GitHub Actions**: CI/CD automation

### Application Stack
- **Backend**: Spring Boot 3.3, Java 21
- **Serverless**: Python 3.11, AWS SAM
- **Observability**: Micrometer, CloudWatch Agent
- **Database**: S3 for object storage

### DevOps Practices
- Infrastructure as Code (Terraform)
- Continuous Integration/Deployment (GitHub Actions)
- Container orchestration (Docker)
- Metrics-driven development (CloudWatch)
- Automated testing and validation

---

## 📊 Exam Tasks Overview

| Task | Description | Points | Status |
|------|-------------|--------|--------|
| 1 | Terraform, S3 & Infrastructure as Code | 15 | ✅ Complete |
| 2 | AWS Lambda, SAM & GitHub Actions | 25 | ✅ Complete |
| 3 | Containers & Docker | 25 | ✅ Complete |
| 4 | Observability, Metrics & CloudWatch | 25 | ✅ Complete |
| 5 | DevOps Principles Essay | 10 | ✅ Complete |

**Total:** 100 points

---

## 📚 Documentation

- **[README_SVAR.md](README_SVAR.md)** - Complete exam answers and implementation details
- **[README_OPPGAVER.md](README_OPPGAVER.md)** - Original exam requirements
- **[infra-s3/README.md](infra-s3/README.md)** - S3 Terraform module documentation
- **[screenshots/](screenshots/)** - CloudWatch dashboard and alarm screenshots

---

## 🔗 Links

- **GitHub Repository:** [PGR301-DevOps-Exam](https://github.com/AlsosCode/PGR301-DevOps-Exam)
- **Docker Hub:** [alsoscode/sentiment-docker](https://hub.docker.com/r/alsoscode/sentiment-docker)
- **API Gateway:** https://8z9glu80ta.execute-api.eu-west-1.amazonaws.com/Prod/analyze/

---

## 📝 Exam Information

**Original Exam Repository:**
[https://github.com/glennbechdevops/pgr301-eksamen-2025](https://github.com/glennbechdevops/pgr301-eksamen-2025)

**Requirements:**
[README_OPPGAVER.md](https://github.com/glennbechdevops/pgr301-eksamen-2025/blob/main/README_OPPGAVER.md)

---

**Note:** This is an exam submission for PGR301 DevOps i Skyen at Kristiania University College.
