# Minikube

## Prerequisites

1. kubectl, https://kubernetes.io/docs/tasks/tools/#specifying-the-vm-driver
2. minikube, https://minikube.sigs.k8s.io/docs/start/

## minikube 

```bash
minikube start --vm-driver=virtualbox  --cpus 4 --memory 8192 --kubernetes-version v1.16.0
minikube addons enable ingress
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

## cert-manager
Setup cert-manager, https://community.hetzner.com/tutorials/howto-k8s-traefik-certmanager#step-31---setup-cert-manager

cert-manager(v0.12)
```bash
# Setup cert-manager
kubectl create namespace cert-manager
kubectl apply --validate=false -f cert-manager.yaml
watch kubectl -n cert-manager get pods
kubectl -n testing describe certificate nginx.minikube-cert

# Create self-signed certificate
kubectl apply -f nginx.yaml
kubectl -n testing get ing

# Create a staging certificate
export YOUR_MAIL_ADDRESS=<your@email>
# create issuer
envsubst < staging.yaml
cat staging.yaml| envsubst| kubectl apply -f -
kubectl describe clusterissuer letsencrypt-staging
# create staging certificate
export DOMAIN=nginx.minikube
envsubst < nginx-letsencrypt-staging.yaml
cat nginx-letsencrypt-staging.yaml| envsubst| kubectl apply --validate=false -f -
watch kubectl -n testing describe certificate "${DOMAIN}-cert"
kubectl -n cert-manager logs -f --tail 20 $(kubectl -n cert-manager get pod -l app=cert-manager -o jsonpath='{.items[0].metadata.name}')
kubectl delete -f nginx-letsencrypt-staging.yaml

```

# harbor
Docking Container Images Alongside Harbor In Minikube, https://medium.com/@Devopscontinens/alongside-harbor-berth-with-minikube-b31e487974f4

quick start
```bash
kubectl create namespace harbor
helm install -f myvalues.yaml harbor harbor/harbor -n harbor

kubectl create secret docker-registry harborsecret --docker-server=core.harbor.domain --docker-username=admin --docker-password=Harbor12345 --docker-email=dragon270329@gmail.com
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "harborsecret"}]}'
```

```bash
helm repo add harbor https://helm.goharbor.io
git clone https://github.com/goharbor/harbor-helm.git
kubectl create namespace harbor
helm install harbor harbor/harbor -n harbor
echo "$(minikube ip) core.harbor.domain" | sudo tee -a /etc/hosts

# docker login
cd /etc/docker/certs.d
sudo mkdir core.harbor.domain
cd core.harbor.domain 
sudo cp ~/Downloads/ca.crt .
docker login core.harbor.domain
docker tag nginx:latest core.harbor.domain/devops/nginx:latest
docker push core.harbor.domain/devops/nginx:latest
```

# insecure
How to Configure GoHarbor as an Insecure Registry for Kubernetes, https://medium.com/devopsturkiye/how-to-configure-goharbor-as-an-insecure-registry-for-kubernetes-e58cd93526a8 

```bash
vim myvalues.yaml
helm upgrade harbor harbor/harbor -n harbor -f myvalues.yaml
sudo vim /etc/docker/daemon.json
# ubuntu
------
{
"insecure-registries" : ["xx.x.x.x"]
}
------
systemctl reload docker
systemctl restart docker
cat ~/.docker/config.json
```

In minikube
```bash
minikube ssh
sudo su
cd /usr/lib/systemd/system/
vi docker.service
# --label provider=virtualbox --insecure-registry 10.0.0.0/12 --insecure-registry core.harbor.domain
systemctl daemon-reload
systemctl restart docker
docker info
```

## Reference

