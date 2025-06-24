#!/bin/bash
set -e

echo "Stopping and deleting Minikube cluster..."
minikube delete

echo "Removing kvinfo.local entry from /etc/hosts..."
sudo sed -i.bak '/kvinfo.local/d' /etc/hosts

echo "Cleanup complete."
