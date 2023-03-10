# Prometheus

See https://prometheus.io

Prometheus is an open source systems monitoring and alerting tool.

## Create Prometheus Secret

The secret contains Kubernetes cluster name:

```
kubectl -n monitoring create secret generic \
  prometheus-cluster-name --from-literal=CLUSTER_NAME=kubernetes-homelab
```

## Deploy Prometheus

```
kubectl apply -f ./prometheus
```
