FROM eclipse-temurin:17-jdk

LABEL maintainer="Allen Efienokwu"
LABEL purpose="Jenkins CI with Docker CLI and Buildx for ARM64"

USER root

RUN apt-get update && \
    apt-get install -y docker.io curl && \
    mkdir -p /usr/lib/docker/cli-plugins && \
    curl -sSL https://github.com/docker/buildx/releases/latest/download/buildx-linux-arm64 \
    -o /usr/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/lib/docker/cli-plugins/docker-buildx

USER jenkins

EXPOSE 8080 50000
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]




# Use a small base that supports arm/amd64 (multi-arch official images)
#FROM python:3.11-slim

#WORKDIR /app
#COPY app.py /app/

#EXPOSE 8080
#CMD ["python", "app.py"]
