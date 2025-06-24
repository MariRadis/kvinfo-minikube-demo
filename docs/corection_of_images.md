1. I use minikube
2. I have one node where kubernetes and pods are running
3. Load balancer is needed if you want to access front end from internet
    you do not need to manually write a manifest for a LoadBalancer service when you're using the Minikube Ingress addon, because:
    The LoadBalancer-type service is automatically created by the NGINX Ingress controller when you run:
    
    ```bash
    minikube addons enable ingress
    ```