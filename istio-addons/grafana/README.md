# Grafana

Grafana is an open source monitoring solution that can be used to configure dashboards for Istio.

## Installation

Istio provides a basic sample installation to quickly get Grafana up and running:
```
kubectl apply -f ./istio-addon-grafana.yml
```

Use port forwarding to access Grafana dashboard:
```
kubectl -n istio-system port-forward svc/grafana 3000:3000
```

## References

https://istio.io/latest/docs/ops/integrations/grafana/
