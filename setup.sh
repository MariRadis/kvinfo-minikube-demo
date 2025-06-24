#!/bin/bash
set -e

echo "🚀 Starting Minikube..."
minikube start --driver=docker

echo "🐳 Using Minikube Docker environment..."
eval $(minikube docker-env)

echo "🔨 Building frontend image..."
docker build -t kvinfo/frontend ./frontend

echo "🔨 Building backend image..."
docker build -t kvinfo/backend ./backend

echo "✅ Enabling Ingress addon..."
minikube addons enable ingress

echo "📦 Applying Kubernetes manifests..."
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
echo "   http://kvinfo.local/api/message"
