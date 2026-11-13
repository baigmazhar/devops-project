#!/bin/bash
# Run this script from your LOCAL machine (Windows Git Bash or WSL)
# after both EC2 instances are up.
# It copies the kubeconfig from K3s EC2 and saves it locally
# so you can upload it to Jenkins as a credential.

K3S_IP=$1

if [ -z "$K3S_IP" ]; then
  echo "Usage: ./copy-kubeconfig.sh <K3S_PUBLIC_IP>"
  exit 1
fi

echo "Fetching kubeconfig from K3s server at $K3S_IP ..."

# Copy the kubeconfig file from K3s EC2
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@${K3S_IP}:/etc/rancher/k3s/k3s.yaml ./k3s-kubeconfig.yaml

# Replace the internal 127.0.0.1 address with the actual K3s public IP
sed -i "s/127.0.0.1/${K3S_IP}/g" ./k3s-kubeconfig.yaml

echo ""
echo "Done! kubeconfig saved to: ./k3s-kubeconfig.yaml"
echo "Now upload this file to Jenkins as a 'Secret File' credential with ID: k3s-kubeconfig"
