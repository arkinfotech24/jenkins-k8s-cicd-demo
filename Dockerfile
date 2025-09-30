# ✅ Base image with ARM64 support
FROM arm64v8/openjdk:17-jdk

LABEL maintainer="Allen Efienokwu"
LABEL purpose="Jenkins CI with Docker CLI and Buildx for ARM64"

# 🛠️ Install Jenkins manually
ENV JENKINS_VERSION=2.426.1
ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_UC=https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_DOWNLOAD=https://get.jenkins.io/war-stable
ENV JENKINS_WAR=${JENKINS_DOWNLOAD}/${JENKINS_VERSION}/jenkins.war

RUN apt-get update && \
    apt-get install -y curl gnupg2 docker.io && \
    curl -fsSL ${JENKINS_WAR} -o /usr/share/jenkins/jenkins.war && \
    mkdir -p ${JENKINS_HOME} && \
    useradd -d ${JENKINS_HOME} -u 1000 -m -s /bin/bash jenkins && \
    chown -R jenkins:jenkins ${JENKINS_HOME} /usr/share/jenkins

# 🔧 Install Docker Buildx plugin for ARM64
RUN mkdir -p /usr/lib/docker/cli-plugins && \
    curl -sSL https://github.com/docker/buildx/releases/latest/download/buildx-linux-arm64 \
    -o /usr/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/lib/docker/cli-plugins/docker-buildx

USER jenkins

EXPOSE 8080 50000

CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]



# # Use a small base that supports arm/amd64 (multi-arch official images)
# FROM python:3.11-slim

# WORKDIR /app
# COPY app.py /app/

# EXPOSE 8080
# CMD ["python", "app.py"]
