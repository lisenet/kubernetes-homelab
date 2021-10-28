# Kubecost

See https://www.kubecost.com

Kubecost helps you monitor and manage cost and capacity in Kubernetes environments. 

## Install Kubecost Using Helm

### Pre-requisites

Add Helm repository:
```
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
```

Create `kubecost` namespace:
```
kubectl create namespace kubecost
```

### Deploy Kubecost 

We are going to integrate Kubecost with our existing Prometheus.

We have to do several things:

* Set `prometheus.enabled` to `false`,
* Set `prometheus.nodeExporter.enabled` to `false`,
* Set `prometheus.fqdn` parameter to match our local Prometheus service address,
* Configure our Prometheus to scrape the cost-model `/metrics` endpoint,
* Add Prometheus recording rules to enable certain Kubecost features.

Note that we can supply any value as a token, it does not seem to be validated, deployment works regardless.

```
helm upgrade --install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --set global.prometheus.enabled=false \
  --set global.prometheus.fqdn="http://prometheus-service.monitoring.svc:9090" \
  --set global.grafana.enabled=true \
  --set kubecostToken="a" \
  --set kubecostModel.imagePullPolicy="IfNotPresent" \
  --set kubecostFrontend.imagePullPolicy="IfNotPresent" \
  --set networkCosts.enabled=true \
  --set persistentVolume.enabled=true \
  --set persistentVolume.size=10Gi \
  --set persistentVolume.storageClass="freenas-nfs-csi" \
  --set prometheus.nodeExporter.enabled=false \
  --set prometheus.server.persistentVolume.enabled=false
```

Create a `LoadBalancer` type service that will expose Kubecost to the network:
```
kubectl apply -f ./kubecost-service.yaml
```
