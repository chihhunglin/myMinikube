# Minikube

## Prerequisites

1. kubectl, https://kubernetes.io/docs/tasks/tools/#specifying-the-vm-driver
2. minikube, https://minikube.sigs.k8s.io/docs/start/

## minikube 

```bash
minikube start --vm-driver=virtualbox  --cpus 4 --memory 8192 --kubernetes-version v1.16.0
minikube dashboard
minikube delete

minikube ip
minikube ssh
```

## metallb
在 Kubernetes Minikube 上安裝 Load Balancer MetalLB, https://www.akiicat.com/2019/04/17/Kubernetes/metallb-installation-for-minikube/

metallb/manifests (v0.7)
```bash
# view bgp
kubectl apply -f test-bgp-router.yaml
minikube service -n metallb-system test-bgp-router-ui

# install metallb
kubectl apply -f metallb.yaml

# config
kubectl apply -f tutorial-3.yaml

# test
kubectl run hello-world --image=k8s.gcr.io/echoserver:1.10 --port=8080
kubectl expose po hello-world --type=LoadBalancer

# verify external ip
kubectl get service
# browser it
minikube service hello-world

# delete
kubectl delete svc hello-world
kubectl delete po hello-world
```

## traefik
Use Traefik and cert-manager to serve a secured website, https://community.hetzner.com/tutorials/howto-k8s-traefik-certmanager

traefik/examples/k8s(1.7)
```bash
# RBAC roles
kubectl apply -f traefik-rbac.yaml

# Setup Traefik
kubectl apply -f traefik-ds.yaml

# Validate setup and get EXTERNAL-IP
kubectl -n kube-system get pod
kubectl -n kube-system get service

# logs
kubectl -n kube-system logs -f $(kubectl -n kube-system get pods -l k8s-app=traefik-ingress-lb  -o jsonpath='{.items[0].metadata.name}')

# logs for all pods
kubectl -n kube-system logs -f -l k8s-app=traefik-ingress-lb

# Open Traefik dashboard
minikube service -n kube-system traefik-ingress-service

# apply ui.yaml to open traefik ui
kubectl apply -f ui.yaml 
echo "$(minikube ip) traefik-ui.minikube" | sudo tee -a /etc/hosts
# http://traefik-ui.minikube/

# nginx
kubectl apply -f nginx.yaml
kubectl get -n testing ing
echo "$(minikube ip) nginx.minikube" | sudo tee -a /etc/hosts
kubectl -n testing logs -f $(kubectl -n testing get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
```



## Reference

