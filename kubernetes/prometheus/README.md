[[Back to Index Page](../README.md)]

# Prometheus

See https://prometheus.io

Prometheus is an open source systems monitoring and alerting tool.

## Create Prometheus Secret

The secret contains Kubernetes cluster name:

```bash
kubectl -n monitoring create secret generic \
  prometheus-cluster-name --from-literal=CLUSTER_NAME=kubernetes-homelab
```

## Deploy Prometheus

```bash
kubectl apply -f ./prometheus
```