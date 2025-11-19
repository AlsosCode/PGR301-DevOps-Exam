# AiAlpha Sentiment Analysis API - Docker

Spring Boot application for AI-powered sentiment analysis using AWS Bedrock Nova.

## Features

- **AI-Powered Analysis**: Uses AWS Bedrock Nova Micro for advanced sentiment analysis
- **Company-Specific Sentiment**: Identifies multiple companies and provides individual sentiment scores
- **S3 Storage**: Automatically stores analysis results in S3
- **CloudWatch Metrics**: Built-in observability with custom metrics
- **Dockerized**: Ready for containerized deployment

## Quick Start with Docker

### Pull from Docker Hub

```bash
docker pull alsoscode/sentiment-docker:latest
```

### Run the container

```bash
docker run -d \
  -e AWS_ACCESS_KEY_ID=your-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret \
  -e S3_BUCKET_NAME=kandidat-6-data \
  -p 8080:8080 \
  alsoscode/sentiment-docker:latest
```

### Test the API

```bash
curl -X POST http://localhost:8080/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "requestId": "test-123",
    "text": "NVIDIA soars on strong earnings while Intel struggles with declining sales"
  }'
```

## Building Locally

### Build the Docker image

```bash
cd sentiment-docker
docker build -t sentiment-docker:local .
```

### Run locally built image

```bash
docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e S3_BUCKET_NAME=kandidat-6-data \
  -p 8080:8080 \
  sentiment-docker:local
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Yes |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Yes |
| `S3_BUCKET_NAME` | S3 bucket for storing results | Yes |
| `AWS_REGION` | AWS region | No (default: eu-west-1) |

## Architecture

### Multi-Stage Docker Build

The Dockerfile uses a two-stage build for optimization:

1. **Build Stage**: Maven 3.9 with Amazon Corretto 21
   - Downloads dependencies (cached layer)
   - Compiles and packages the application

2. **Runtime Stage**: Amazon Corretto 21 Alpine
   - Minimal runtime environment
   - Non-root user for security
   - Health check configured
   - JVM tuned for containers

### Image Size Optimization

- Multi-stage build reduces final image size
- Alpine-based runtime image
- .dockerignore excludes unnecessary files
- Maven dependency caching

## Health Check

The container includes a health check endpoint:

```bash
curl http://localhost:8080/actuator/health
```

## Docker Hub

**Repository**: https://hub.docker.com/r/alsoscode/sentiment-docker

**Available Tags**:
- `latest` - Latest build from main branch
- `kandidat-6` - Candidate-specific tag
- `kandidat-6-sha-<commit>` - Commit-specific tags

## CI/CD

The application is automatically built and published to Docker Hub via GitHub Actions when changes are pushed to the `sentiment-docker/` directory.

See [.github/workflows/docker-build.yml](../.github/workflows/docker-build.yml) for the CI/CD configuration.

## Security Features

- ✅ Non-root user execution
- ✅ Minimal Alpine base image
- ✅ Health checks configured
- ✅ Environment-based configuration (no secrets in image)
- ✅ JVM container support enabled

## Metrics & Observability

The application exports custom metrics to CloudWatch:
- Sentiment analysis request counts
- API response times
- Company detection metrics
- Confidence score distributions

See Task 4 documentation for detailed metrics configuration.
# Trigger Docker build
