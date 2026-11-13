#!/bin/bash
# This script runs automatically when the K3s EC2 starts
# It installs K3s (lightweight Kubernetes)

set -e
exec > /var/log/user_data.log 2>&1

echo "=== Starting K3s EC2 Setup ==="

# Update system
apt-get update -y
apt-get upgrade -y

# Install K3s (single-node Kubernetes cluster)
# --write-kubeconfig-mode 644 allows non-root users to read kubeconfig
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Enable and start K3s
systemctl enable k3s
systemctl start k3s

# Wait for K3s to be ready
sleep 30

echo "=== K3s EC2 Setup Complete ==="
echo "Kubeconfig is at: /etc/rancher/k3s/k3s.yaml"
