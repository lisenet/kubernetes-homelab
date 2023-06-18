[[Back to Index Page](../README.md)]

# X.509 Certificate Exporter

See https://github.com/enix/x509-certificate-exporter

A Prometheus exporter for certificates focusing on expiration monitoring.

## Install x509-certificate-exporter using Helm

Add Helm repository:

```bash
helm repo add enix https://charts.enix.io
```

Create `monitoring` namespace:

```bash
kubectl create namespace monitoring
```

Deploy x509-certificate-exporter:

```bash
helm upgrade --install \
  x509-certificate-exporter \
  enix/x509-certificate-exporter \
  --namespace monitoring \
  --version "1.20.0" \
  --values ./values.yml
```