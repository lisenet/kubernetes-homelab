[[Back to Index Page](../README.md)]

# Velero Backups

See https://velero.io and https://github.com/vmware-tanzu/helm-charts

## Pre-requisites

Add Helm repository:

```bash
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
```

Create `velero` namespace:

```bash
kubectl create namespace velero
```

## Configure S3 Bucket and Credentials

Create an S3 bucket using Terraform:

```bash
cd ./terraform && terraform init && terraform apply
```

Save IAM user's access keys in a file `velero-credentials.txt`, e.g.:

```ini
[default]
aws_access_key_id = REDACTED
aws_secret_access_key = REDACTED
```

## Deploy Velero using Helm

```bash
helm upgrade --install velero \
  vmware-tanzu/velero \
  --namespace velero \
  --version "2.28.1" \
  --set-file credentials.secretContents.cloud=velero-credentials.txt \
  --values ./values.yaml
```

## Install Velero Client

Once velero server is up and running you need the client before you can use it:

```bash
wget https://github.com/vmware-tanzu/velero/releases/download/v1.8.1/velero-v1.8.1-linux-amd64.tar.gz
tar xf velero-v1.8.1-linux-amd64.tar.gz 
sudo mv velero-v1.8.1-linux-amd64/velero /usr/local/bin/
sudo chown root:root /usr/local/bin/velero 
```

## Verify Backup Location

```bash
velero backup-location get
NAME      PROVIDER   BUCKET/PREFIX                       PHASE       LAST VALIDATED                  ACCESS MODE   DEFAULT
default   aws        kubernetes-homelab-velero-backups   Available   2022-03-20 23:25:35 +0000 GMT   ReadWrite     true
```

## Create a Backup

Backup a single namespace:

```bash
velero backup create monitoring --include-namespaces monitoring
velero backup describe monitoring
```

Create a backup job for each namespace:

```bash
for i in $(kubectl get ns -o name|cut -d"/" -f2|grep -ve velero);do
  velero backup create "${i}" --include-namespaces "${i}"
done
```

Create a backup schedule for each namespace:

```bash
for i in $(kubectl get ns -o name|cut -d"/" -f2|grep -ve velero);do
  velero create schedule "${i}" --schedule="0 2 * * *" --include-namespaces "${i}"
done
```

## Check Backups and Schedules

```bash
velero backup get
NAME                   STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
default                Completed   0        0          2022-03-20 23:23:18 +0000 GMT   29d       default            <none>
democratic-csi         Completed   0        0          2022-03-20 23:23:21 +0000 GMT   29d       default            <none>
httpd-healthcheck      Completed   0        0          2022-03-20 23:23:25 +0000 GMT   29d       default            <none>
istio-system           Completed   0        0          2022-03-20 23:23:28 +0000 GMT   29d       default            <none>
kube-node-lease        Completed   0        0          2022-03-20 23:23:32 +0000 GMT   29d       default            <none>
kube-public            Completed   0        0          2022-03-20 23:23:35 +0000 GMT   29d       default            <none>
kube-system            Completed   0        0          2022-03-20 23:23:38 +0000 GMT   29d       default            <none>
kubecost               Completed   0        0          2022-03-20 23:23:46 +0000 GMT   29d       default            <none>
kubernetes-dashboard   Completed   0        0          2022-03-20 23:23:51 +0000 GMT   29d       default            <none>
logging                Completed   0        0          2022-03-20 23:23:54 +0000 GMT   29d       default            <none>
metallb-system         Completed   0        0          2022-03-20 23:23:57 +0000 GMT   29d       default            <none>
monitoring             Completed   0        0          2022-03-20 23:24:01 +0000 GMT   29d       default            <none>
openvpn                Completed   0        0          2022-03-20 23:24:06 +0000 GMT   29d       default            <none>
pii-demo               Completed   0        0          2022-03-20 23:24:09 +0000 GMT   29d       default            <none>
speedtest              Completed   0        0          2022-03-20 23:22:42 +0000 GMT   29d       default            <none>
```

```bash
velero schedule get
NAME                   STATUS    CREATED                         SCHEDULE    BACKUP TTL   LAST BACKUP   SELECTOR
default                Enabled   2022-03-20 23:24:26 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
democratic-csi         Enabled   2022-03-20 23:24:26 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
httpd-healthcheck      Enabled   2022-03-20 23:24:27 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
istio-system           Enabled   2022-03-20 23:24:27 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
kube-node-lease        Enabled   2022-03-20 23:24:27 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
kube-public            Enabled   2022-03-20 23:24:27 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
kube-system            Enabled   2022-03-20 23:24:28 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
kubecost               Enabled   2022-03-20 23:24:28 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
kubernetes-dashboard   Enabled   2022-03-20 23:24:28 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
logging                Enabled   2022-03-20 23:24:29 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
metallb-system         Enabled   2022-03-20 23:24:29 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
monitoring             Enabled   2022-03-20 23:24:29 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
openvpn                Enabled   2022-03-20 23:24:30 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
pii-demo               Enabled   2022-03-20 23:24:30 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
speedtest              Enabled   2022-03-20 23:24:30 +0000 GMT   0 2 * * *   720h0m0s     n/a           <none>
```