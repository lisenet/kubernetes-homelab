[[Back to Index Page](../README.md)]

# Certified Kubernetes Security Specialist (CKS)

Preparation and study material for Certified Kubernetes Security Specialist exam v1.27.

- [Reasoning](#reasoning)
- [Aliases](#aliases)
- [Allowed Kubernetes documentation resources](#allowed-kubernetes-documentation-resources)
- [CKS Environment](#cks-environment)
- [CKS Exam Simulator](#cks-exam-simulator)
- [Prep: Cluster Installation and Configuration](#prep-cluster-installation-and-configuration)
    - [Provision underlying infrastructure to deploy a Kubernetes cluster](#provision-underlying-infrastructure-to-deploy-a-kubernetes-cluster)
    - [Use Kubeadm to install a basic cluster](#use-kubeadm-to-install-a-basic-cluster)
    - [Install Podman and ETCD client](#install-podman-and-etcd-client)

## Reasoning

Having passed CKA and CKAD earlier, the time has come to complete the Kubernetes trilogy.

## Aliases

Keep it simple:

```bash
alias k=kubectl
alias do="--dry-run=client -o yaml"
alias now="--force --grace-period 0"

alias kc="kubectl config"
alias kcgc="kubectl config get-contexts"
alias kccc="kubectl config current-context"
```

## Allowed Kubernetes documentation resources

* [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [kubectl-commands Reference](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
* [Kubernetes Documentation](https://kubernetes.io/docs)
* [Kubernetes Blog](https://kubernetes.io/blog)
* [Trivy Documentation](https://aquasecurity.github.io/trivy/)
* [Falco Documentation](https://falco.org/docs/)
* [ETCD Documentation](https://etcd.io/docs/)
* [App Armor Documentation](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)

## CKS Environment

See https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks#cks-environment

Sixteen (16) clusters comprise the CKS exam environment, one for each task. Each cluster is made up of one master node and one worker node.

At the start of each task you'll be provided with the command to ensure you are on the correct cluster to complete the task.

Command-like tools `kubectl`, `jq`, `tmux`, `curl`, `wget` and `man` are pre-installed in all environments.

## CKS Exam Simulator

https://killer.sh/cks

Do not sit the CKS exam unless you get the perfect score **and** understand the solutions (regardless of the time taken to solve all questions).

![CKS Simulator](./images/killer-shell-cks-simulator.png)

## Prep: Cluster Installation and Configuration

**This section is not part of CKS exam objectives**, however, we need to build a Kubernetes cluster to practise on.

### Provision underlying infrastructure to deploy a Kubernetes cluster

We have a [six-node](../images/kubernetes-homelab-diagram.png) (three control planes and three worker nodes) Kubernetes homelab cluster running [Rocky Linux](https://www.lisenet.com/2021/migrating-ha-kubernetes-cluster-from-centos-7-to-rocky-linux-8/) already.

For the purpose of our CKS studies, we will create a new two-node cluster, with one control plane and one worker node, using Ubuntu 20.04 LTS. It makes sense to use a Debian-based distribution here because we have a RHEL-based homelab cluster already.

Libvirt/KVM nodes:

* srv37-master: 2 vCPUs, 4GB RAM, 16GB disk, 10.11.1.37/24
* srv38-node: 2 vCPUs, 4GB RAM, 16GB disk, 10.11.1.38/24

Provision a KVM guest for the **control plane** using PXE boot:

```bash
virt-install \
  --connect qemu+ssh://root@kvm1.hl.test/system \
  --name srv37-master \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:37 \
  --disk path=/var/lib/libvirt/images/srv37.qcow2,size=16 \
  --pxe \
  --ram 4096 \
  --vcpus 2 \
  --os-type linux \
  --os-variant ubuntu20.04 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --wait 0
```

When asked for an OS, select Ubuntu 20.04 LTS Server option.

![PXE boot menu](../images/homelab-pxe-boot-menu.png)

Provision a KVM guest for the **worker node** using PXE boot:

```bash
virt-install \
  --connect qemu+ssh://root@kvm1.hl.test/system \
  --name srv38-node \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:38 \
  --disk path=/var/lib/libvirt/images/srv38.qcow2,size=16 \
  --pxe \
  --ram 4096 \
  --vcpus 2 \
  --os-type linux \
  --os-variant ubuntu20.04 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --wait 0
```

### Use Kubeadm to install a basic cluster

Docs:
* https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
* https://kubernetes.io/docs/setup/production-environment/container-runtimes/
* https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

We will use `kubeadm` to install a Kubernetes v1.27 cluster.

Install container runtime on all nodes:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
```

Install `containerd` on all nodes:

```bash
sudo apt-get update -qq
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -qq
sudo apt-get -y install containerd.io

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```

To use the `systemd` cgroup driver in `/etc/containerd/config.toml` with `runc`, set:

```bash
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
```

Make sure to restart containerd:

```bash
sudo systemctl restart containerd
```

Install `kubeadm`, `kubelet` and `kubectl` (v1.27):

```bash
curl -sSfL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb [trusted=yes] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -qq
sudo apt-get install -y kubelet=1.27.3-00 kubeadm=1.27.3-00 kubectl=1.27.3-00
sudo apt-mark hold kubelet kubeadm kubectl

cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--container-runtime-endpoint unix:///run/containerd/containerd.sock"
EOF

sudo systemctl enable kubelet --now
```

Initialise the **control plane** node. Set pod network CIDR to `192.168.0.0/16` that is based on the Calico CNI that supports network policies.

```bash
sudo kubeadm init \
  --kubernetes-version "1.27.3" \
  --pod-network-cidr "192.168.0.0/16"
```

Configure `kubectl` access on the **control plane**:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Install Calico pod network to the cluster.

```bash
kubectl apply -f "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
```

Run the output of the init command on the **worker node**:

```bash
kubeadm join 10.11.1.37:6443 --token gr1um5.gt3u8etw8u3kt3ei \
  --discovery-token-ca-cert-hash sha256:d2ad1f4b98e7dc95af6408714cb25e335550b420ba00aa397dfb3efc4db550aa
```

Check the cluster to make sure that all nodes are running and ready:

```bash
kubectl get no -o wide
NAME    STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
srv37   Ready    control-plane   2m54s   v1.27.3   10.11.1.37    <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.6.21
srv38   Ready    <none>          35s     v1.27.3   10.11.1.38    <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.6.21
```

### Install Podman and ETCD Client

While installation of these tools is not part of the CKS exam objectives, we are going to need to have them on our system in order to solve tasks.

Use these commands to install Podman on Ubuntu 20.04:

```bash
VERSION_ID="20.04"
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get install -y podman cri-tools containers-common

cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF
```

Install ETCD:

```bash
ETCD_VER=v3.5.9
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GITHUB_URL}
mkdir -p /tmp/etcd-download-test
curl -fsSL ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo mv /tmp/etcd-download-test/etcdctl /usr/local/bin/

/usr/local/bin/etcdctl version
etcdctl version: 3.5.9
API version: 3.5
```

