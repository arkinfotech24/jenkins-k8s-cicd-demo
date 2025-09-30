# Base Jenkins image
FROM jenkins/jenkins:lts

USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean

# Optional: Install buildx plugin (if needed for multi-arch builds)
RUN mkdir -p ~/.docker/cli-plugins && \
    curl -sSL https://github.com/docker/buildx/releases/latest/download/buildx-linux-amd64 -o ~/.docker/cli-plugins/docker-buildx && \
    chmod +x ~/.docker/cli-plugins/docker-buildx

USER jenkins

# # Use a small base that supports arm/amd64 (multi-arch official images)
# FROM python:3.11-slim

# WORKDIR /app
# COPY app.py /app/

# EXPOSE 8080
# CMD ["python", "app.py"]
