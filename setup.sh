#!/bin/bash
set -e

# What it does:
#   Starts Minikube with Docker
#
#   Enables Ingress
#
#   Applies all Kubernetes manifests
#
#   Automatically updates /etc/hosts with kvinfo.local
#
#   Displays access URLs

echo "🔧 Starting Minikube..."
minikube start --driver=docker

echo "✅ Enabling Ingress addon..."
minikube addons enable ingress

echo "📦 Applying Kubernetes manifests..."
kubectl apply -f k8s-manifests/frontend-configmap.yaml
kubectl apply -f k8s-manifests/frontend.yaml
kubectl apply -f k8s-manifests/backend.yaml
kubectl apply -f k8s-manifests/db.yaml
kubectl apply -f k8s-manifests/ingress.yaml

echo "🌐 Configuring /etc/hosts entry..."
MINIKUBE_IP=$(minikube ip)
if ! grep -q "kvinfo.local" /etc/hosts; then
  echo "$MINIKUBE_IP kvinfo.local" | sudo tee -a /etc/hosts
else
  echo "ℹ️ Hosts entry already exists."
fi

echo "🚀 Deployment complete. Visit:"
echo "   http://kvinfo.local/frontend"
echo "   http://kvinfo.local/backend"
