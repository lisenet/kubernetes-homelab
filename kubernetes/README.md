[[Back to Index Page](../README.md)]

# Kubernetes Resources

This directory contains Kubernetes resources that are defined in YAML and to be deployed using `kubectl`.

The [helm](./helm/) directory contains Kubernetes resources that are to be deployed using `helm`.

## Prerequisites

This section covers software tools that you need to install to use Kubernetes resources.

### Kubectl

Install `kubectl` on a RHEL-based system:

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name = kubernetes
baseurl = https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled = 1
gpgcheck = 1
gpgkey = https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
skip_if_unavailable = 1
EOF

sudo yum install kubectl
```

Install `kubectl` on a Debian-based system:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl software-properties-common
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo add-apt-repository -y "deb https://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install kubectl
```

### Helm

Install `helm` on a RHEL-based system:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 0700 ./get_helm.sh
./get_helm.sh
rm -f ./get_helm.sh
```

Install `helm` on a Debian-based system:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https curl software-properties-common
curl -fsSL https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo add-apt-repository -y "deb https://baltocdn.com/helm/stable/debian/ all main"
sudo apt-get update
sudo apt-get install helm
```

Add Helm repositories:

```bash
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo add enix https://charts.enix.io
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update
```

### Istioctl

Install `istioctl`:

```bash
ISTIO_VERSION="1.19.0"
curl -fsSL -o istioctl.tar.gz "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istioctl-${ISTIO_VERSION}-linux-amd64.tar.gz"
tar xf istioctl.tar.gz && rm -f istioctl.tar.gz
sudo mv istioctl /usr/local/bin/
sudo chmod 0755 /usr/local/bin/istioctl
istioctl version
```

