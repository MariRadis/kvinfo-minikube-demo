#!/bin/bash
set -e

echo "🧹 Deleting Minikube cluster..."
minikube delete

echo "🧼 Removing /etc/hosts entry..."
sudo sed -i.bak '/kvinfo.local/d' /etc/hosts

echo "✅ Teardown complete."
