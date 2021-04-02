# Kiali

Kiali is an observability console for Istio with service mesh configuration and validation capabilities. 

## Installation

Istio provides a basic sample installation to quickly get Kiali up and running:
```
kubectl apply -f ./istio-1.9-samples-addons-kiali.yml
```

Use port forwarding to Access Kiali dashboard:
```
kubectl -n istio-system port-forward svc/kiali 20001:20001
```

## References

https://istio.io/latest/docs/ops/integrations/kiali/
