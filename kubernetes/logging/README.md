[[Back to Index Page](../README.md)]

# Grafana Loki and Promtail for Logging

See https://grafana.com/docs/loki/latest/

## Pre-requisites

Create `logging` namespace:

```bash
kubectl create namespace logging
```

## Deploy Loki using Kubectl

```bash
kubectl apply -f ./loki-pvc.yml
kubectl apply -f ./loki-deployment.yml
```

## Deploy Promtail using Kubectl

```bash
kubectl apply -f ./promtail-deployment.yml
```

