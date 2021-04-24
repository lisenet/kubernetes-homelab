# TrueNAS with democratic-csi

Democratic CSI implements the container storage interface spec providing storage for Kubernetes.

See https://github.com/democratic-csi/democratic-csi

## Helm Installation

```
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update
helm search repo democratic-csi/
```

## Install the democratic-csi Helm Chart

This uses our `freenas-nfs.yaml` values file:

```
helm upgrade \
  --install \
  --create-namespace \
  --values freenas-nfs.yaml \
  --namespace democratic-csi \
  zfs-nfs democratic-csi/democratic-csi
```
