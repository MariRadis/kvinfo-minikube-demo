#!/bin/bash
set -euo pipefail

echo "Starting Minikube with Docker driver..."
minikube start --driver=docker

echo "Configuring Docker to use Minikube's environment..."
eval "$(minikube docker-env)"

echo "Building Docker images inside Minikube's Docker environment..."
docker build -t kvinfo/frontend:latest ./frontend
docker build -t kvinfo/backend:latest ./backend

echo "Enabling Ingress addon..."
minikube addons enable ingress

echo "Applying core Kubernetes manifests (DB, backend, frontend)..."
kubectl apply -f k8s-manifests/db.yaml
kubectl apply -f k8s-manifests/backend.yaml
kubectl apply -f k8s-manifests/frontend.yaml

echo "Waiting for Ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "Applying Ingress manifest..."
kubectl apply -f k8s-manifests/ingress.yaml

echo "Waiting for deployments to become available..."
kubectl wait --for=condition=available --timeout=60s deployment/frontend
kubectl wait --for=condition=available --timeout=60s deployment/backend

echo "Configuring /etc/hosts entry for kvinfo.local..."
MINIKUBE_IP=$(minikube ip)
if ! grep -q "kvinfo.local" /etc/hosts; then
  echo "$MINIKUBE_IP kvinfo.local" | sudo tee -a /etc/hosts
else
  echo "Hosts entry already exists."
fi

echo "Deployment complete."
echo "Visit in browser:"
echo "   http://kvinfo.local/frontend"
echo "   http://kvinfo.local/api/message"
