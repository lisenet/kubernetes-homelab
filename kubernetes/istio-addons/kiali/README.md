[[Back to Index Page](../../README.md)]

# Kiali

Kiali is an observability console for Istio with service mesh configuration and validation capabilities. 

## Installation

Istio provides a basic sample installation to quickly get Kiali up and running:

```bash
kubectl apply -f ./istio-addon-kiali.yml
```

Use port forwarding to Access Kiali dashboard:

```bash
kubectl -n istio-system port-forward svc/kiali 20001:20001
```

## References

https://istio.io/latest/docs/ops/integrations/kiali/
