
# KVInfoSysBund Minikube Demo

This is a minimal Kubernetes deployment of a sample web application, for local testing using Minikube.

## 🔧 Components

- **Frontend**: Static HTML served by NGINX
- **Backend**: Simple echo service (`hashicorp/http-echo`)
- **Database**: PostgreSQL
- **Ingress**: Route `/frontend` and `/backend` via Ingress

## 📦 How to Run Locally

### 1. Start Minikube

```bash
minikube start --driver=docker
```

### 2. Apply Manifests

```bash
kubectl apply -f k8s-manifests/frontend-configmap.yaml
kubectl apply -f k8s-manifests/frontend.yaml
kubectl apply -f k8s-manifests/backend.yaml
kubectl apply -f k8s-manifests/db.yaml
kubectl apply -f k8s-manifests/ingress.yaml
```

### 3. Enable Ingress (if not enabled)

```bash
minikube addons enable ingress
```

### 4. Access in Browser

```bash
echo "$(minikube ip) kvinfo.local" | sudo tee -a /etc/hosts
```

- [http://kvinfo.local/frontend](http://kvinfo.local/frontend)
- [http://kvinfo.local/backend](http://kvinfo.local/backend)

## 🚀 GitHub Actions

Included `.github/workflows/minikube.yml` runs the deployment inside a GitHub Actions CI pipeline using Minikube.

## 📁 Folder Structure

```
kvinfo-minikube-demo/
├── k8s-manifests/
│   ├── backend.yaml
│   ├── db.yaml
│   ├── frontend.yaml
│   ├── frontend-configmap.yaml
│   └── ingress.yaml
├── .github/
│   └── workflows/
│       └── minikube.yml
└── README.md
```
