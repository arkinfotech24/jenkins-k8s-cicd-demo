#!/bin/bash
set -euxo pipefail

echo "🔧 Fixing broken packages (if any)..."
sudo apt-get -y --fix-broken install || true

echo "📦 Updating package index..."
sudo apt-get update || true

echo "☕ Adding Java 21 PPA..."
sudo add-apt-repository -y ppa:openjdk-r/ppa || true
sudo apt-get update || true

echo "☕ Installing Java 21..."
for i in {1..3}; do
  if sudo apt-get install -y openjdk-21-jdk; then
    break
  fi
  echo "Retrying Java install ($i)..."
  sleep 5
done

echo "🔍 Validating Java installation..."
java --version || { echo "Java installation failed"; exit 1; }

echo "📦 Adding Jenkins repository and GPG key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "🔄 Updating package index with Jenkins repo..."
sudo apt-get update || true

echo "🚀 Installing Jenkins..."
sudo apt-get install -y jenkins || { echo "Jenkins installation failed"; exit 1; }

echo "🛡️ Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "✅ Validating Jenkins service..."
sudo systemctl is-active --quiet jenkins && echo "Jenkins is running" || {
  echo "Jenkins failed to start"
  sudo journalctl -u jenkins --no-pager | tail -n 20
  exit 1
}

echo "🔐 Exporting Jenkins initial admin password..."
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /tmp/jenkins-admin-password.txt
  echo "✅ Jenkins admin password saved to /tmp/jenkins-admin-password.txt"
else
  echo "⚠️ Jenkins admin password not found"
fi

echo "📡 Validating AWS SSM Agent (Snap-based)..."
if snap list amazon-ssm-agent &>/dev/null; then
  sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent
  sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent
  sudo systemctl is-active --quiet snap.amazon-ssm-agent.amazon-ssm-agent && echo "SSM Agent is running" || {
    echo "SSM Agent failed to start"
    sudo journalctl -u snap.amazon-ssm-agent.amazon-ssm-agent --no-pager | tail -n 20
    exit 1
  }
else
  echo "⚠️ SSM Agent not found via Snap"
fi

echo "🧹 Cleaning up unused packages..."
sudo apt-get autoremove -y
sudo apt-get clean

echo "🎉 Provisioning complete!"
