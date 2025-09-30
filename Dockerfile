# Base Jenkins image
FROM jenkins/jenkins:lts

LABEL maintainer="Allen Efienokwu"
LABEL purpose="Jenkins CI with Docker CLI and Buildx for ARM64"

USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io curl && \
    apt-get clean

# Install Docker Buildx plugin for ARM64
RUN mkdir -p /usr/lib/docker/cli-plugins && \
    curl -sSL https://github.com/docker/buildx/releases/latest/download/buildx-linux-arm64 \
    -o /usr/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/lib/docker/cli-plugins/docker-buildx

# Optional: Validate Docker and Buildx availability
RUN docker --version && \
    docker buildx version || echo "⚠️ Buildx not available"

USER jenkins


# # Use a small base that supports arm/amd64 (multi-arch official images)
# FROM python:3.11-slim

# WORKDIR /app
# COPY app.py /app/

# EXPOSE 8080
# CMD ["python", "app.py"]
