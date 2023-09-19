[[Back to Index Page](../../README.md)]

# Prometheus

Prometheus is an open source monitoring system and time series database.

## Installation

Istio provides a basic sample installation to quickly get Prometheus up and running:

```bash
kubectl apply -f ./istio-addon-prometheus.yml
```

Use port forwarding to access Prometheus dashboard:

```bash
kubectl -n istio-system port-forward svc/prometheus 9090:9090
```

## References

https://istio.io/latest/docs/ops/integrations/prometheus/
