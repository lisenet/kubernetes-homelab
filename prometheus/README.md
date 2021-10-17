## Create Prometheus Secret

The secret contains Kubernetes cluster name:

```
kubectl -n monitoring create secret generic prometheus-cluster-name --from-literal=CLUSTER_NAME=kubernetes-homelab
```
