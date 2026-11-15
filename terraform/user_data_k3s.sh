#!/bin/bash
# This script runs automatically when the K3s EC2 starts
# It installs K3s (lightweight Kubernetes)

set -e
exec > /var/log/user_data.log 2>&1

echo "=== Starting K3s EC2 Setup ==="

# Update system
apt-get update -y
apt-get upgrade -y

# Install K3s with public IP binding so kubectl can reach it remotely
# --tls-san adds the public IP to the TLS certificate
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --tls-san $PUBLIC_IP

# Enable and start K3s
systemctl enable k3s
systemctl start k3s

# Wait for K3s to be ready
sleep 30

echo "=== K3s EC2 Setup Complete ==="
echo "Kubeconfig is at: /etc/rancher/k3s/k3s.yaml"
