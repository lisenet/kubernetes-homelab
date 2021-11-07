# X.509 Certificate Exporter

See https://github.com/enix/x509-certificate-exporter

A Prometheus exporter for certificates focusing on expiration monitoring.

## Install x509-certificate-exporter using Helm

Add Helm repository:
```
helm repo add enix https://charts.enix.io
```

Create `monitoring` namespace:
```
kubectl create namespace monitoring
```

Deploy x509-certificate-exporter:

```
helm install x509-certificate-exporter \
  enix/x509-certificate-exporter \
  --namespace monitoring \
  --values ./values.yml
```
