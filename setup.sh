#!/bin/bash
set -euo pipefail

echo "Starting Minikube with Docker driver..."
minikube start --driver=docker

echo "Configuring Docker to use Minikube's environment..."
eval "$(minikube docker-env)"

echo "Building Docker images inside Minikube..."
docker build -t kvinfo/frontend:latest ./frontend
docker build -t kvinfo/backend:latest ./backend

echo "Enabling Ingress addon..."
minikube addons enable ingress

echo "Applying core Kubernetes manifests (DB, backend, frontend)..."
kubectl apply -f k8s-manifests/db.yaml
kubectl apply -f k8s-manifests/backend.yaml
kubectl apply -f k8s-manifests/frontend.yaml

echo "Waiting for Ingress controller to become ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "Applying Ingress manifest..."
kubectl apply -f k8s-manifests/ingress.yaml

echo "Waiting for frontend and backend deployments to become available..."
kubectl wait --for=condition=available --timeout=180s deployment/frontend
kubectl wait --for=condition=available --timeout=180s deployment/backend

echo "Starting 'minikube tunnel' in background..."
sudo pkill -f "minikube tunnel" || true
sudo nohup minikube tunnel > /dev/null 2>&1 &

echo "Waiting for LoadBalancer IP from Ingress..."
INGRESS_IP=""
for i in {1..20}; do
  INGRESS_IP=$(kubectl get ingress kvinfo-ingress -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2>/dev/null || true)
  if [[ -n "$INGRESS_IP" ]]; then
    break
  fi
  echo "Waiting for ingress IP..."
  sleep 3
done

if [[ -z "$INGRESS_IP" ]]; then
  echo "Failed to retrieve Ingress IP. Check if 'minikube tunnel' is running and Ingress is configured correctly."
  exit 1
fi

echo "Configuring /etc/hosts entry for kvinfo.local..."
if grep -q "kvinfo.local" /etc/hosts; then
  echo "Updating existing entry..."
  sudo sed -i '' "s/.*kvinfo.local.*/$INGRESS_IP kvinfo.local/" /etc/hosts
else
  echo "$INGRESS_IP kvinfo.local" | sudo tee -a /etc/hosts
fi

echo "Deployment complete!"
echo ""
echo "Visit in your browser:"
echo "http://kvinfo.local/frontend"
echo "http://kvinfo.local/api/message"
