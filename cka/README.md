# Certified Kubernetes Administrator (CKA)

Preparation and study material for Certified Kubernetes Administrator exam v1.26.

- [Reasoning](#reasoning)
- [Aliases](#aliases)
- [Allowed Kubernetes documentation resources](#allowed-kubernetes-documentation-resources)
- [CKA Environment](#cka-environment)
- [CKA Exam Simulator](#cka-exam-simulator)
- [Cluster Architecture, Installation and Configuration](#cluster-architecture-installation-and-configuration)
    - [Provision underlying infrastructure to deploy a Kubernetes cluster](#provision-underlying-infrastructure-to-deploy-a-kubernetes-cluster)
    - [Use Kubeadm to install a basic cluster](#use-kubeadm-to-install-a-basic-cluster)
    - [Implement etcd backup and restore](#implement-etcd-backup-and-restore)
    - [Perform a version upgrade on a Kubernetes cluster using Kubeadm](#perform-a-version-upgrade-on-a-kubernetes-cluster-using-kubeadm)
    - [Manage role based access control (RBAC)](#manage-role-based-access-control-rbac)
    - [Manage a highly-available Kubernetes cluster](#manage-a-highly-available-kubernetes-cluster)
- [Workloads and Scheduling](#workloads-and-scheduling)
    - [Understand deployments and how to perform rolling update and rollbacks](#understand-deployments-and-how-to-perform-rolling-update-and-rollbacks)
    - [Use ConfigMaps and Secrets to configure applications](#use-configmaps-and-secrets-to-configure-applications)
    - [Know how to scale applications](#know-how-to-scale-applications)
    - [Understand the primitives used to create robust, self-healing, application deployments](#understand-the-primitives-used-to-create-robust-self-healing-application-deployments)
    - [Understand how resource limits can affect Pod scheduling](#understand-how-resource-limits-can-affect-pod-scheduling)
    - [Awareness of manifest management and common templating tools](#awareness-of-manifest-management-and-common-templating-tools)
- [Services and Networking](#services-and-networking)
    - [Understand host networking configuration on the cluster nodes](#understand-host-networking-configuration-on-the-cluster-nodes)
    - [Understand connectivity between Pods](#understand-connectivity-between-pods)
    - [Understand ClusterIP, NodePort, LoadBalancer service types and endpoints](#understand-clusterip-nodeport-loadbalancer-service-types-and-endpoints)
    - [Know how to use Ingress controllers and Ingress resources](#know-how-to-use-ingress-controllers-and-ingress-resources)
    - [Know how to configure and use CoreDNS](#know-how-to-configure-and-use-coredns)
    - [Choose an appropriate container network interface plugin](#choose-an-appropriate-container-network-interface-plugin)
- [Storage](#storage)
    - [Understand storage classes, persistent volumes](#understand-storage-classes-persistent-volumes)
    - [Understand volume mode, access modes and reclaim policies for volumes](#Understand-volume-mode-access-modes-and-reclaim-policies-for-volumes)
    - [Understand persistent volume claims primitive](#understand-persistent-volume-claims-primitive)
    - [Know how to configure applications with persistent storage](#know-how-to-configure-applications-with-persistent-storage)
- [Troubleshooting](#troubleshooting)
    - [Evaluate cluster and node logging](#evaluate-cluster-and-node-logging)
    - [Understand how to monitor applications](#understand-how-to-monitor-applications)
    - [Manage container stdout and stderr logs](#manage-container-stdout-and-stderr-logs)
    - [Troubleshoot application failure](#troubleshoot-application-failure)
    - [Troubleshoot cluster component failure](#troubleshoot-cluster-component-failure)
    - [Troubleshoot networking](#troubleshoot-networking)
- [Bonus Exercise: am I ready for the CKA exam?](#bonus-exercise-am-i-ready-for-the-cka-exam)

## Reasoning

After using Kubernetes in production for over a year now (both on-prem and AWS/EKS), I wanted to see what the CKA exam is all about.

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
* [GitHub Kubernetes](https://github.com/kubernetes/kubernetes)
* [Kubernetes Blog](https://kubernetes.io/blog)

## CKA Environment

See https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad#cka-and-ckad-environment

There are six clusters (CKA) that comprise the exam environment, made up of varying numbers of containers, as follows:

Cluster | Members | CNI | Description
--- | --- | --- | ---
k8s | 1 master, 2 worker | flannel | k8s cluster
hk8s | 1 master, 2 worker | calico | k8s cluster
bk8s | 1 master, 1 worker | flannel | k8s cluster
wk8s | 1 master, 2 worker | flannel | k8s cluster
ek8s | 1 master, 2 worker | flannel | k8s cluster
ik8s | 1 master, 1 base node | loopback | k8s cluster − missing worker node

At the start of each task you'll be provided with the command to ensure you are on the correct cluster to complete the task.

Command-like tools `kubectl`, `jq`, `tmux`, `curl`, `wget` and `man` are pre-installed in all environments.

## CKA Exam Simulator

https://killer.sh/cka

Do not sit the CKA exam unless you get the perfect score **and** understand the solutions (regardless of the time taken to solve all questions).

![CKA Simulator](./images/killer-shell-cka-simulator.png)

## Cluster Architecture, Installation and Configuration

Unless stated otherwise, all Kubernetes resources should be created in the `cka` namespace.

### Provision underlying infrastructure to deploy a Kubernetes cluster

We have a [six-node](../docs/kubernetes-homelab-diagram.png) (three control planes and three worker nodes) Kubernetes homelab cluster running [Rocky Linux](https://www.lisenet.com/2021/migrating-ha-kubernetes-cluster-from-centos-7-to-rocky-linux-8/) already.

For the sake of this excercise, we will create a new two-node cluster, with one control plane and one worker node, using Ubuntu 20.04 LTS. It makes sense to use a Debian-based distribution here because we have a RHEL-based homelab cluster already.

Libvirt/KVM nodes:

* srv39-master: 2 vCPUs, 4GB RAM, 16GB disk, 10.11.1.39/24
* srv40-node: 2 vCPUs, 4GB RAM, 16GB disk, 10.11.1.40/24

Provision a KVM guest for the **control plane**:

```bash
virt-install \
  --connect qemu+ssh://root@kvm1.hl.test/system \
  --name srv39-master \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:39 \
  --disk path=/var/lib/libvirt/images/srv39.qcow2,size=16 \
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

Provision a KVM guest for the **worker node**:

```bash
virt-install \
  --connect qemu+ssh://root@kvm1.hl.test/system \
  --name srv40-node \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:40 \
  --disk path=/var/lib/libvirt/images/srv40.qcow2,size=16 \
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

We will use `kubeadm` to install a Kubernetes v1.25 cluster. We will upgrade the cluster to v1.26 in the next chapter.

Docs: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

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
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get -y install containerd.io

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```

To use the `systemd` cgroup driver in `/etc/containerd/config.toml` with `runc`, set:

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

Make sure to restart containerd:

```bash
sudo systemctl restart containerd
```

Docs: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

Install `kubeadm`, `kubelet` and `kubectl` (v1.25):

```bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.25.5-00 kubeadm=1.25.5-00 kubectl=1.25.5-00
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
```

Docs: https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

Initialise the **control plane** node. Set pod network CIDR based on the CNI that you plan to install later:

* Calico - `192.168.0.0/16`
* Flannel - `10.244.0.0/16`
* Weave Net - `10.32.0.0/12`

We are going to use Flannel, hence `10.244.0.0/16`.

```bash
sudo kubeadm init \
  --kubernetes-version "1.25.5" \
  --pod-network-cidr "10.244.0.0/16"
```

Configure `kubectl` access on the **control plane**:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Run the output of the init command on the **worker node**:

```bash
kubeadm join 10.11.1.39:6443 --token "ktlb43.llip8nym905afakm" \
	--discovery-token-ca-cert-hash sha256:b3f1c31e2777bd54b3f7a797659a96072711809ae84e8c9be3fba449c8e32dd4
```

Install a pod network to the cluster. You can choose one of the following: Calico, Flannel, Weave Net.

* To install Calico, run the following:

```bash
kubectl apply -f "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
```

* To install Flannel (for Kubernetes v1.17+), run the following:

```bash
kubectl apply -f "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
```

* To install Weave Net, run the following:

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

Check the cluster to make sure that all nodes are running and ready:

```bash
kubectl get nodes
NAME    STATUS   ROLES                  AGE    VERSION
srv39   Ready    control-plane,master   14m    v1.25.5
srv40   Ready    <none>                 102s   v1.25.5
```

### How to add new worker nodes to the cluster?

Docs: https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/

Create a new token on the control plane:

```bash
kubeadm token create --print-join-command
```

The output will be something like this:

```bash
kubeadm join 10.11.1.39:6443 --token hh{truncated}g4 --discovery-token-ca-cert-hash sha256:77{truncated}28
```

Run the `kubeadm join` command on a new worker node that is to be added to the cluster.

### Implement etcd backup and restore

Docs: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

Install etcd client package on the **control plane** using a package manager (this may not always install the version of the package that you want):

```bash
sudo apt-get -y install etcd-client
```

Alternativelly:

```bash
ETCD_VER=v3.5.2
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GITHUB_URL}

mkdir -p /tmp/etcd-download-test
curl -fsSL ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/tmp/etcd-download-test/etcdctl version
etcdctl version: 3.5.2
API version: 3.5
```

Find paths of certificates and keys:

```bash
egrep "cert-|key-|trusted-" /etc/kubernetes/manifests/etcd.yaml|grep -ve peer
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

Take a snapshot by specifying the endpoint and certificates:

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save "/root/etcd_backup_$(date +%F).db"
```

Do not use `snapshot status` command because it can alter the snapshot file and render it invalid.

Restore an etcd cluster from the snapshot. Identify the default `data-dir`:

```bash
grep data-dir /etc/kubernetes/manifests/etcd.yaml
    - --data-dir=/var/lib/etcd
```

If any API servers are running in your cluster, you should not attempt to restore instances of etcd. Instead, follow these steps to restore etcd:

* Stop all API server instances.
* Restore state in all etcd instances.
* Restart all API server instances.

Stop all control plane components:

```bash
cd /etc/kubernetes/manifests/
mv ./*yaml ../
```

Make sure all control plane pods are `NotReady`:

```bash
crictl pods | egrep "kube|etcd"
```

Restore the snapshot into a specific directory:

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --data-dir /var/lib/etcd_backup \
  snapshot restore "/root/etcd_backup_$(date +%F).db"
```

Tell etcd to use the new directory `/var/lib/etcd_backup`:

```bash
sed -i 's/\/var\/lib\/etcd/\/var\/lib\/etcd_backup/g' /etc/kubernetes/manifests/etcd.yaml
```

Start all control plane components:

```bash
cd /etc/kubernetes/manifests/
mv ../*yaml ./
```

Give it some time (up to several minutes) for etcd to restart.

### Perform a version upgrade on a Kubernetes cluster using Kubeadm

Docs: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

We will upgrade previously deployed Kubernetes cluster v1.25 to v1.26.

Find the latest version in the list:

```bash
apt-get update
apt-cache madison kubeadm
```

Upgrade the **control plane**:

```bash
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.26.1-00 && \
apt-mark hold kubeadm

kubeadm version
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.26.1

kubectl drain srv39 --ignore-daemonsets

apt-mark unhold kubelet kubectl && \
apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00 && \
apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet
kubectl uncordon srv39
```

Upgrade the **worker node**:

```bash
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.26.1-00 && \
apt-mark hold kubeadm

sudo kubeadm upgrade node

kubectl drain srv40 --ignore-daemonsets

apt-mark unhold kubelet kubectl && \
apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00 && \
apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet
kubectl uncordon srv40
```

Verify the status of the cluster:

```bash
kubectl get nodes
NAME    STATUS   ROLES                  AGE   VERSION
srv39   Ready    control-plane,master   38m   v1.26.1
srv40   Ready    <none>                 33m   v1.26.1
```

### Manage role based access control (RBAC)

Docs: 
* https://kubernetes.io/docs/reference/access-authn-authz/rbac/
* https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/
* https://kubernetes.io/docs/tasks/administer-cluster/certificates/

**Exercise 1**: perform the following tasks.

1. Create a new user called `peasant` and grant the user access to the Kubernetes cluster.
2. Generate a private key `peasant.key` and CSR `peasant.csr` for the user.
3. User should have permissions to `get` and `list` the following resources in the `cka` namespace: `pods` and `services`.
4. Check API access using the `auth can-i` subcommand.

A few steps are required in order to get a normal user to be able to authenticate and invoke an API. First, this user must have a certificate issued by the Kubernetes cluster, and then present that certificate to the Kubernetes API.

Create a private key and a CSR using `openssl`:

```bash
openssl genrsa -out peasant.key 2048
openssl req -new -key peasant.key -out peasant.csr
```

Create a `CertificateSigningRequest` and submit it to a Kubernetes cluster:

```bash
cat peasant.csr | base64 | tr -d "\n"

cat > peasant-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: peasant
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2lEQ0NBWEFDQVFBd1F6RUxNQWtHQTFVRUJoTUNSMEl4RURBT0JnTlZCQWdNQjBodmJXVnNZV0l4RURBTwpCZ05WQkFvTUIwaHZiV1ZzWVdJeEVEQU9CZ05WQkFNTUIzQmxZWE5oYm5Rd2dnRWlNQTBHQ1NxR1NJYjNEUUVCCkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEYm4xd3c5bExDbERDd1EyeTlsVE1sSG9SUHNJS0VmbnFvb25mUmZiMnQKdzE5dzhrK3BGbkJsQkVxNEtSTldHSThnRkpab2MvS0lJN25lUnQwVDNnSkcrV09hWW56M2lYK3liL3IyNmh6ZwpTUWVWVjJCVEYxTVp3T0FmcjJpa2dPN1l4Z1YrZ0gwNFRmU1hKRUdSa2hUWEs4bWZzT3NrMHpnWW1NRHgvSkxpCmVZSWdlSkZMVnhoeCtUU3B2NzZQREk4OEJrVXpQbzYrQ2hXaExPcHRsL041Ym5BWXpXY2hIa2VTbGEwcC9UNnAKZ2RtR0tPOXkyN3k5bUx0MnJkd1Q2Tld5cXBsQk9ZbzloZ0VzKy9BYm5CSllvc0VMUzBKZmxpai90S3hEUyt0Qwp5YUY5NmQ0eTd3MUE3eVk4bmxZV3VIOFRUbXg4N0VySHA2OE16eUlZcmVYSkFnTUJBQUdnQURBTkJna3Foa2lHCjl3MEJBUXNGQUFPQ0FRRUFOMVIzY2Z4bTErZ0NiS1hxK0oyUkJ4eUFrSnFxNzF0SlZBemJmT3dScDV6REk4WTAKUHhCYlpBTjVGZVh3UFRyZnlPNm50TDFWSy9vTW9ETXoxTXNPZDZ5OXp6RGZYaHZRb3EvWW1Yd1g3M05iVzhJNQpweG1PRWkyeTZydEd2eVA2SHpicmtGTnNiVklPRktWMWhPSU9neitvd25TOFpUNWZzQmZOdXQ3eTRJTEZydmNRCnl6Mk0rWlAyWm96VlZ0NE9GaXNSSUF1MGlocE5Uc0ZLNkZUM3ZjblQ4bnZHQm5rS0NEeEh2YmRWVVdDK2xIZmkKZDI2Q3FwVmxQemNQRnRqRCtYQyswU2UzamJ1eW40MkxJYzRkaVBHUDA0a2Nsa2NLLzF1Z2NITHNCSjZZUGdyeQpSc05iQkhCSHM3c1hvNUw4NHIyOGlTL0RWR281d2tSd2hHNzlwUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl apply -f peasant-csr.yaml
```

Approve certificate signing request:

```bash
kubectl get csr
NAME      AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
peasant   10s   kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Pending

kubectl certificate approve peasant
```

Create a role and rolebinding:

```bash
kubectl create role peasant-role --resource=pods,svc --verb=get,list -n cka
kubectl create rolebinding peasant-role-binding --role=peasant-role --user=peasant -n cka
```

Verify:

```bash
kubectl auth can-i get pods --as=peasant -n cka
yes

kubectl auth can-i delete pods --as=peasant -n cka
no

kubectl auth can-i list svc --as=peasant -n cka
yes

kubectl auth can-i update svc --as=peasant -n cka
no
```

**Exercise 2**: perform the following tasks.

1. Create a new service account `kubernetes-dashboard-sa`.
2. Create a cluster role `kubernetes-dashboard-clusterrole` that grants permissions `get,list,watch` to resources `pods,nodes` to API group `metrics.k8s.io`.
3. Grant the service account access to the cluster by creating a cluster role binding `kubernetes-dashboard-role-binding`.


Create a service account:

```bash
kubectl create sa kubernetes-dashboard-sa -n cka
```

Create a cluser role:

```bash
kubectl create clusterrole kubernetes-dashboard-clusterrole \
  --verb=get,list,watch --resource=pods,nodes \
  --dry-run=client -o yaml | sed 's/- ""/- metrics.k8s.io/g' | kubectl apply -f -
```

Create a cluster role binding:

```bash
kubectl create clusterrolebinding kubernetes-dashboard-role-binding \
  --clusterrole=kubernetes-dashboard-clusterrole \
  --serviceaccount=cka:kubernetes-dashboard-sa
```

### Manage a highly-available Kubernetes cluster

Docs: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/

A stacked HA cluster is a topology where the distributed data storage cluster provided by etcd is stacked on top of the cluster formed by the nodes managed by kubeadm that run control plane components. This is the default topology in kubeadm.

![Stacked etcd topology](./images/kubeadm-ha-topology-stacked-etcd.png)

Create a kube-apiserver load balancer with a name that resolves to DNS. Install HAProxy and allow it to listen on kube-apiserver port 6443, configure firewall to allow inbound HAProxy traffic on kube-apiserver port 6443.

```bash
sudo apt-get -y install haproxy psmisc
```

Configure HAProxy <code>/etc/haproxy/haproxy.cfg</code>:

```
global
  log /dev/log  local0
  log /dev/log  local1 notice
  stats socket /var/lib/haproxy/stats level admin
  chroot /var/lib/haproxy
  user haproxy
  group haproxy
  daemon

defaults
  log global
  mode  http
  option  httplog
  option  dontlognull
        timeout connect 5000
        timeout client 50000
        timeout server 50000

frontend kubernetes
    bind 10.11.1.30:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server srv31-master 10.11.1.31:6443 check fall 3 rise 2
    server srv32-master 10.11.1.32:6443 check fall 3 rise 2
    server srv33-master 10.11.1.33:6443 check fall 3 rise 2
```

Configure DNS:

```bash
host kubelb.hl.test
kubelb.hl.test has address 10.11.1.30
```

Enable and start HAProxy service:

```bash
sudo systemctl enable --now haproxy
```

Initialise the control plane:

```bash
sudo kubeadm init \
  --control-plane-endpoint "kubelb.hl.test:6443" \
  --upload-certs
```

Join other control plane nodes to the cluster.

## Workloads and Scheduling

Unless stated otherwise, all Kubernetes resources should be created in the `cka` namespace.

### Understand deployments and how to perform rolling update and rollbacks

Docs: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment

**Exercise 1**: perform the following tasks.

1. Create a deployment object `httpd-pii-demo` consisting of 4 pods, each containing a single `lisenet/httpd-pii-demo:0.2` container. It should be able to run on master nodes as well.
2. Identify the update strategy employed by this deployment.
3. Modify the update strategy so `maxSurge` is equal to `50%` and `maxUnavailable` is equal to `50%`.
4. Perform a rolling update to this deployment so that the image gets updated to `lisenet/httpd-pii-demo:0.3`.
5. Undo the most recent change.

Imperative commands:

```bash
kubectl create deploy httpd-pii-demo --image=lisenet/httpd-pii-demo:0.2 --replicas=4 -n cka
kubectl describe deploy httpd-pii-demo -n cka
kubectl edit deploy httpd-pii-demo -n cka
kubectl set image deploy/httpd-pii-demo httpd-pii-demo=lisenet/httpd-pii-demo:0.3 -n cka
kubectl rollout undo deploy/httpd-pii-demo -n cka
kubectl rollout status deploy/httpd-pii-demo -n cka
```

Declarative YAML (updated):

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: httpd-pii-demo
  name: httpd-pii-demo
  namespace: cka
spec:
  replicas: 4
  selector:
    matchLabels:
      app: httpd-pii-demo
  strategy:
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 50%
  template:
    metadata:
      labels:
        app: httpd-pii-demo
    spec:
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
      containers:
      - image: lisenet/httpd-pii-demo:0.2
        name: httpd-pii-demo
```

Docs:
* https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
* https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

**Exercise 2**: perform the following tasks.

1. Create a single pod `httpd` of image `httpd:2.4`. The container should be named `webserver`.
2. This pod should only be scheduled on a control plane node.

Imperative commands:

```bash
kubectl run httpd --image=httpd:2.4 --dry-run=client -o yaml -n cka > httpd-control-plane.yaml
```

Edit the file `httpd-control-plane.yaml` and add `tolerations` and `nodeSelector` sections:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd
  name: httpd
spec:
  containers:
  - image: httpd:2.4
    name: webserver
  restartPolicy: Always
  tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
    operator: Exists
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
```

Deploy the pod:

```bash
kubectl apply -f ./httpd-control-plane.yaml
```

### Use ConfigMaps and Secrets to configure applications

Docs: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

**Exercise 1**: perform the following tasks to configure application to use a configmap.

1. Create a configmap `webapp-color` that has the following key=value pair:
    * `key` = color
    * `value` = blue
2. Create a pod `webapp-color` that uses `kodekloud/webapp-color` image.
3. Configure the pod so that the underlying container has the environent variable `APP_COLOR` set to the value of the configmap.
4. Check pod logs to ensure that the variable has been set correctly.

Imperative commands:

```bash
kubectl create cm webapp-color --from-literal=color=blue -n cka
kubectl run webapp-color --image=kodekloud/webapp-color \
  --dry-run=client -o yaml -n cka > webapp-color.yaml
```

Edit the file `webapp-color.yaml` and add `env` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webapp-color
  name: webapp-color
  namespace: cka
spec:
  containers:
  - image: kodekloud/webapp-color
    name: webapp-color
    env:
      # Define the environment variable
      - name: APP_COLOR
        valueFrom:
          configMapKeyRef:
            # The ConfigMap containing the value you want to assign to APP_COLOR
            name: webapp-color
            # Specify the key associated with the value
            key: color
```

Deploy the pod and validate:

```bash
kubectl apply -f webapp-color.yml
kubectl logs webapp-color -n cka | grep "Color from environment variable"
```

Declarative YAML:

```yaml
---
apiVersion: v1
data:
  color: blue
kind: ConfigMap
metadata:
  name: webapp-color
  namespace: cka
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webapp-color
  name: webapp-color
  namespace: cka
spec:
  containers:
  - image: kodekloud/webapp-color
    name: webapp-color
    env:
      # Define the environment variable
      - name: APP_COLOR
        valueFrom:
          configMapKeyRef:
            # The ConfigMap containing the value you want to assign to APP_COLOR
            name: webapp-color
            # Specify the key associated with the value
            key: color
```

**Exercise 2**: perform the following tasks to configure application to use a configmap.

1. Create a configmap `grafana-ini` that containes a file named `grafana.ini` with the following content:
```ini
[server]
  protocol = http
  http_port = 3000
```
2. Create a pod `grafana` that uses `grafana/grafana:8.1.2` image.
3. Mount the configmap to the pod using `/etc/grafana/grafana.ini` as a `mountPath` and `grafana.ini` as a `subPath`.

Imperative commands:

```bash
cat > grafana.ini <<EOF
[server]
  protocol = http
  http_port = 3000
EOF

kubectl create configmap grafana-ini --from-file=grafana.ini -n cka

kubectl run grafana --image=grafana/grafana:8.1.2 \
  --dry-run=client -o yaml -n cka > grafana.yaml
```

Edit the file `grafana.yaml` and add `volumes` and `volumeMounts` sections:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: grafana
  name: grafana
  namespace: cka
spec:
  containers:
  - image: grafana/grafana:8.1.2
    name: grafana
    volumeMounts:
      - name: grafana-config
        mountPath: /etc/grafana/grafana.ini
        subPath: grafana.ini
  volumes:
    - name: grafana-config
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: grafana-ini
```

Deploy the pod and verify:

```bash
kubectl apply -f grafana.yml

kubectl exec grafana -n cka -- cat /etc/grafana/grafana.ini
[server]
  protocol = http
  http_port = 3000
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-ini
  namespace: cka
data:
  grafana.ini: |
    [server]
      protocol = http
      http_port = 3000
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: grafana
  name: grafana
  namespace: cka
spec:
  containers:
  - image: grafana/grafana:8.1.2
    name: grafana
    volumeMounts:
      - name: grafana-config
        mountPath: /etc/grafana/grafana.ini
  volumes:
    - name: grafana-config
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: grafana-ini
```

Docs: https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables

**Exercise 3**: perform the following tasks to configure application to use a secret.

1. Create a secret `mysql-credentials` that has the following key=value pairs:
    * `mysql_root_password` = Mysql5.7RootPassword
    * `mysql_username` = dbadmin
    * `mysql_password` = Mysql5.7UserPassword
2. Create a pod `mysql-pod-secret` that uses `mysql:5.7` image.
3. Configure the pod so that the underlying container has the following environment variables set:
    * `MYSQL_ROOT_PASSWORD` from secret key `mysql_root_password`
    * `MYSQL_USER` from secret key `mysql_username`
    * `MYSQL_PASSWORD` from secret key `mysql_password`
4. Exec a command in the container to show that it has the configured environment variable.

Imperative commands:

```bash
kubectl create secret generic mysql-credentials \
  --from-literal=mysql_root_password="Mysql5.7RootPassword" \
  --from-literal=mysql_username=dbadmin \
  --from-literal=mysql_password="Mysql5.7UserPassword" \
  -n cka

kubectl run mysql-pod-secret --image=mysql:5.7 \
  --dry-run=client -o yaml -n cka > mysql-pod-secret.yaml
```

Edit the file `mysql-pod-secret.yaml` and add `env` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: mysql-pod-secret
  name: mysql-pod-secret
  namespace: cka
spec:
  containers:
  - image: mysql:5.7
    name: mysql-pod-secret
    env:
      - name: MYSQL_ROOT_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-credentials
            key: mysql_root_password
      - name: MYSQL_USER
        valueFrom:
          secretKeyRef:
            name: mysql-credentials
            key: mysql_username
      - name: MYSQL_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-credentials
            key: mysql_password
```

Deploy the pod and validate:

```bash
kubectl apply -f mysql-pod-secret.yaml
```
```bash
kubectl exec mysql-pod-secret -n cka -- env | grep ^MYSQL
MYSQL_MAJOR=5.7
MYSQL_VERSION=5.7.37-1debian10
MYSQL_ROOT_PASSWORD=Mysql5.7RootPassword
MYSQL_USER=dbadmin
MYSQL_PASSWORD=Mysql5.7UserPassword
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-credentials
  namespace: cka
data:
  mysql_password: TXlzcWw1LjdVc2VyUGFzc3dvcmQ=
  mysql_root_password: TXlzcWw1LjdSb290UGFzc3dvcmQ=
  mysql_username: ZGJhZG1pbg==
type: Opaque
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: mysql-pod-secret
  name: mysql-pod-secret
  namespace: cka
spec:
  containers:
  - image: mysql:5.7
    name: mysql-pod-secret
    env:
      - name: MYSQL_ROOT_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-credentials
            key: mysql_root_password
      - name: MYSQL_USER
        valueFrom:
          secretKeyRef:
            name: mysql-credentials
            key: mysql_username
      - name: MYSQL_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-credentials
            key: mysql_password
```

### Know how to scale applications

Docs: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment

**Exercise**: perform the following tasks.

1. Create a deployment object `nginx-deployment` consisting of 2 pods containing a single `nginx:1.21` container.
2. Increase the deployment size by adding 1 additional pod. Record the action.
3. Decrease the deployment back to its original size of 2 pods. Record the action.

Imperative commands:

```bash
kubectl create deploy nginx-deployment --image=nginx:1.21 --replicas=2 -n cka
kubectl scale deploy nginx-deployment --replicas=3 --record -n cka
kubectl scale deploy nginx-deployment --replicas=2 --record -n cka
```

Declarative YAML (initial):

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
  namespace: cka
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.21
        name: nginx
```

Declarative YAML (updated):

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
  namespace: cka
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.21
        name: nginx
```

### Understand the primitives used to create robust, self-healing, application deployments

Docs: 
* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ 
* https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
* https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
* https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

**Exercise 1**: perform the following tasks.

1. Create a pod `httpd-liveness-readiness` that uses `lisenet/httpd-healthcheck:1.0.0` image.
2. Configure both `liveness` and `readiness` probes for a TCP check on port `10001`.
3. Set `initialDelaySeconds` to 5. The probe should be performed every 10 seconds.

Imperative commands:

```bash
kubectl run httpd-liveness-readiness --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n cka > httpd-liveness-readiness.yaml
```

Edit the file `httpd-liveness-readiness.yaml` and add probes:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-liveness-readiness
  name: httpd-liveness-readiness
  namespace: cka
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-liveness-readiness
    readinessProbe:
      tcpSocket:
        port: 10001
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 10001
      initialDelaySeconds: 5
      periodSeconds: 10
```

Deploy the pod:

```bash
kubectl apply -f httpd-liveness-readiness.yaml
```

Verify:

```bash
kubectl describe po/httpd-liveness-readiness -n cka | grep tcp
    Liveness:       tcp-socket :10001 delay=5s timeout=1s period=10s #success=1 #failure=3
    Readiness:      tcp-socket :10001 delay=5s timeout=1s period=10s #success=1 #failure=3
```

**Exercise 2**: perform the following tasks.

1. Create a pod called `multi-container` that has the following:
    * A container named `blue` with `lisenet/httpd-pii-demo:0.2` image.
    * A container named `healthcheck` with `lisenet/httpd-healthcheck:1.0.0` image.
    * An `initContainer` named `busybox` with `busybox:1.35.0` image. Container runs the following command: `echo FIRST`.

Imperative commands:

```bash
kubectl run multi-container --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n cka > multi-container.yaml
```

Edit the file `multi-container.yaml` and add containers.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multi-container
  name: multi-container
  namespace: cka
spec:
  containers:
  - image: lisenet/httpd-pii-demo:0.2
    name: blue
  - image: lisenet/httpd-healthcheck:1.0.0
    name: healthcheck
  initContainers:
  - name: busybox
    image: busybox:1.35.0
    command: ['sh', '-c', 'echo FIRSH']
```

Deploy the pod and verify that 2 containers are running:

```bash
kubectl apply -f multi-container.yaml

kubectl get po/multi-container -n cka
NAME              READY   STATUS    RESTARTS   AGE
multi-container   2/2     Running   0          11s
```

### Understand how resource limits can affect Pod scheduling

Docs: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#example-1

**Exercise 1**: perform the following tasks.

1. Create a pod `httpd-healthcheck` that uses `lisenet/httpd-healthcheck:1.0.0` image.
2. Set the pod memory request to 40Mi and memory limit to 128Mi.

Imperative commands:

```bash
kubectl run httpd-healthcheck --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n cka > httpd-healthcheck.yaml
```

Edit the file `httpd-healthcheck.yaml` and add `resources` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-healthcheck
  name: httpd-healthcheck
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-healthcheck
    resources:
      requests:
        memory: 40Mi
      limits:
        memory: 128Mi
```

Deploy the pod:

```bash
kubectl apply -f httpd-healthcheck.yaml
```

Verify:

```bash
kubectl describe po/httpd-healthcheck -n cka | grep -B1 memory
    Limits:
      memory:  128M
    Requests:
      memory:     40M
```

Docs: https://kubernetes.io/docs/concepts/policy/limit-range/

**Exercise 2**: perform the following tasks.

1. Create a namespace `cka-memlimit` with a container memory limit of 30Mi.
2. Create a pod `httpd-healthcheck-memlimit` that uses `lisenet/httpd-healthcheck:1.0.0` image in the `cka-memlimit` namespace, and set the pod memory request to 100Mi.
3. Observe the error.

Imperative commands:

```bash
kubectl create ns cka-memlimit

cat > cka-memlimit.yaml <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: cka-memlimit
  namespace: cka-memlimit
spec:
  limits:
  - max:
      memory: 30Mi
    type: Container
EOF

kubectl apply -f cka-memlimit.yaml

kubectl run httpd-healthcheck-memlimit --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n cka-memlimit > httpd-healthcheck-memlimit.yaml
```

Edit the file `httpd-healthcheck-memlimit.yaml` and add `resources` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-healthcheck-memlimit
  name: httpd-healthcheck-memlimit
  namespace: cka-memlimit
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-healthcheck-memlimit
    resources:
      requests:
        memory: 100Mi
```

Deploy the pod:

```bash
kubectl apply -f httpd-healthcheck-memlimit.yaml
The Pod "httpd-healthcheck-memlimit" is invalid: spec.containers[0].resources.requests: Invalid value: "100Mi": must be less than or equal to memory limit
```

### Awareness of manifest management and common templating tools

Docs: https://kubernetes.io/blog/2016/10/helm-charts-making-it-simple-to-package-and-deploy-apps-on-kubernetes/

Helm is the package manager (analogous to yum and apt) and Charts are packages (analogous to debs and rpms).

## Services and Networking

Unless stated otherwise, all Kubernetes resources should be created in the `cka` namespace.

### Understand host networking configuration on the cluster nodes

Doc: https://kubernetes.io/docs/concepts/cluster-administration/networking/

**Exercise 1**: perform the following tasks.

1. Change the Service CIDR to `10.112.0.0/12` for the cluster.
2. Create a new service `new-cluster-ip` of type `ClusterIP` that exposes port `8080`.
3. Save the `iptables` rules of the control plane node for the created service `new-cluster-ip` to a file `/tmp/iptables.txt`.

Imperative commands. Check the cluster IP:

```bash
kubectl get svc/kubernetes
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   12d
```

Change the Service CIDR on the kube-apiserver:

```bash
sed -i 's/10.96.0.0/10.112.0.0/g' /etc/kubernetes/manifests/kube-apiserver.yaml
```

Give it a some time for the kube-apiserver to restart. Check the pod was restarted using `crictl`:

```bash
crictl ps | grep kube-controller-manager
a34270848373d  f40be0088a83e  About a minute ago  Running  kube-apiserver ...
```

Do the same for the controller manager:

```bash
sed -i 's/10.96.0.0/10.112.0.0/g' /etc/kubernetes/manifests/kube-controller-manager.yaml
```

Give it some time for the controller-manager to restart. Check the pod was restarted using `crictl`:

```bash
crictl ps | grep kube-controller-manager
e5666a46b88ac  b07520cd7ab76  46 seconds ago  Running  kube-controller-manager ...
```

Create a new service and verify its IP address:

```bash
kubectl create svc clusterip new-cluster-ip --tcp 8080

kubectl get svc/new-cluster-ip
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
new-cluster-ip   ClusterIP   10.118.114.114   <none>        8080/TCP   7s
```

Kubernetes services are implemented using `iptables` rules on all nodes. Save firewall rules for the service:

```bash
iptables-save | grep new-cluster-ip > /tmp/iptables.txt
```

### Understand connectivity between Pods

Doc: https://kubernetes.io/docs/concepts/services-networking/

Every Pod gets its own IP address. This means you do not need to explicitly create links between Pods and you almost never need to deal with mapping container ports to host ports.

Kubernetes imposes the following fundamental requirements on any networking implementation (barring any intentional network segmentation policies):

* pods on a node can communicate with all pods on all nodes without NAT,
* agents on a node (e.g. system daemons, kubelet) can communicate with all pods on that node.

Note: For those platforms that support Pods running in the host network (e.g. Linux):

* pods in the host network of a node can communicate with all pods on all nodes without NAT.

Kubernetes IP addresses exist at the Pod scope - containers within a Pod share their network namespaces - including their IP address and MAC address. This means that containers within a Pod can all reach each other's ports on localhost. This also means that containers within a Pod must coordinate port usage, but this is no different from processes in a VM. This is called the "IP-per-pod" model.

Docs: https://kubernetes.io/docs/concepts/services-networking/network-policies/

**Exercise 1**: perform the following tasks.

1. Create a pod `httpd-netpol-blue` that uses image `lisenet/httpd-pii-demo:0.2` and has a label of `app=blue`.
2. Create a pod `httpd-netpol-green` that uses image `lisenet/httpd-pii-demo:0.3` and has a label of `app=green`.
3. Create a pod `curl-netpol` that uses image `curlimages/curl:7.81.0` and has a label of `app=admin`. The pod should run the following command `sleep 1800`.
4. Create a `NetworkPolicy` called `netpol-blue-green`.
5. The policy should allow the `busybox` pod only to:
    * connect to `httpd-netpol-blue` pods on port `80`.
6. Use the `app` label of pods in your policy.

After implementation, connections from `busybox` pod to `httpd-netpol-green` pod on port `80` should no longer work.

Imperative commands. Create pods:

```bash
kubectl run httpd-netpol-blue --image="lisenet/httpd-pii-demo:0.2" --labels=app=blue -n cka
kubectl run httpd-netpol-green --image="lisenet/httpd-pii-demo:0.3" --labels=app=green -n cka
kubectl run curl-netpol --image="curlimages/curl:7.81.0" --labels=app=admin -n cka -- sleep 1800
```

Get IP addresses of pods and test web access.

```bash
kubectl get po -o wide -n cka | awk '{ print $1" "$6 }'
NAME IP
curl-netpol 192.168.135.204
httpd-netpol-blue 192.168.137.36
httpd-netpol-green 192.168.137.40

kubectl -n cka exec curl-netpol -- curl -sI http://192.168.137.36
HTTP/1.1 200 OK
Date: Mon, 21 Feb 2022 01:05:37 GMT
Server: Apache/2.4.48 (Debian)
X-Powered-By: PHP/7.3.30
Content-Type: text/html; charset=UTF-8

kubectl -n cka exec curl-netpol -- curl -sI http://192.168.137.40
HTTP/1.1 200 OK
Date: Mon, 21 Feb 2022 01:05:37 GMT
Server: Apache/2.4.48 (Debian)
X-Powered-By: PHP/7.3.30
Content-Type: text/html; charset=UTF-8
```

Create a file `netpol-blue-green.yaml` with the following content:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: netpol-blue-green
  namespace: cka
spec:
  podSelector:
    matchLabels:
      app: admin
  policyTypes:
    - Egress # policy is only about Egress
  egress:
    - to: # first condition "to"
      - podSelector:
          matchLabels:
            app: blue
      ports: # second condition "port"
      - protocol: TCP
        port: 80
```

Create the network policy and verify:

```bash
kubectl apply -f netpol-blue-green.yaml

kubectl get networkpolicy -n cka
NAME                POD-SELECTOR   AGE
netpol-blue-green   app=admin      29s
```

Test web access again:

```bash
kubectl -n cka exec curl-netpol -- curl -sI --max-time 5 http://192.168.137.36
HTTP/1.1 200 OK
Date: Mon, 21 Feb 2022 01:05:37 GMT
Server: Apache/2.4.48 (Debian)
X-Powered-By: PHP/7.3.30
Content-Type: text/html; charset=UTF-8

kubectl -n cka exec curl-netpol -- curl -sI --max-time 5 http://192.168.137.40
command terminated with exit code 28
```

Declarative YAML:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: netpol-blue-green
  namespace: cka
spec:
  podSelector:
    matchLabels:
      app: admin
  policyTypes:
    - Egress
  egress:
    - to:
      - podSelector:
          matchLabels:
            app: blue
      ports:
      - protocol: TCP
        port: 80
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: blue
  name: httpd-netpol-blue
  namespace: cka
spec:
  containers:
  - image: lisenet/httpd-pii-demo:0.2
    name: httpd-netpol-blue
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: green
  name: httpd-netpol-green
  namespace: cka
spec:
  containers:
  - image: lisenet/httpd-pii-demo:0.3
    name: httpd-netpol-green
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: admin
  name: curl-netpol
  namespace: cka
spec:
  containers:
  - args:
    - "sleep"
    - "1800"
    image: curlimages/curl:7.81.0
    name: curl-netpol
```

### Understand ClusterIP, NodePort, LoadBalancer service types and endpoints

Docs: https://kubernetes.io/docs/concepts/services-networking/service/

Pods are nonpermanent resources. If you use a Deployment to run your app, it can create and destroy Pods dynamically. Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.

A service is an abstraction which defines a logical set of Pods and a policy by which to access them. Types of services:

* **ClusterIP** - exposes the Service on an internal IP in the cluster. Service only reachable from within the cluster.
* **NodePort** - exposing services to external clients.E ach cluster node opens a port on the node itself (hence the name) and redirects traffic received on that port to the underlying service.
* **LoadBalancer** - exposing services to external clients. A LoadBalancer service accessible through a dedicated load balancer, provisioned from the Cloud infrastructure Kubernetes is running on.

**Exercise 1**: perform the following tasks.

1. Create a pod `httpd-healthcheck-nodeport` that uses `lisenet/httpd-healthcheck:1.0.0` image.
2. Expose the pod's port `10001` through a service of type `NodePort` and set the node port to `30080`.
3. Get the index page through the `NodePort` using `curl`.

Imperative commands:

```bash
kubectl run httpd-healthcheck-nodeport --image=lisenet/httpd-healthcheck:1.0.0 -n cka

kubectl expose pod httpd-healthcheck-nodeport \
  --port=10001 \
  --target-port=10001 \
  --type=NodePort \
  --dry-run=client -o yaml \
  -n cka > httpd-healthcheck-nodeport.yaml
```

Edit the file `httpd-healthcheck-nodeport.yaml` and add the given node port:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: httpd-healthcheck-nodeport
  name: httpd-healthcheck-nodeport
  namespace: cka
spec:
  ports:
  - port: 10001
    protocol: TCP
    targetPort: 10001
    nodePort: 30080
  selector:
    run: httpd-healthcheck-nodeport
  type: NodePort
```

Deploy the service and verify:

```bash
kubectl apply -f httpd-healthcheck-nodeport.yaml

kubectl describe svc/httpd-healthcheck-nodeport -n cka
Name:                     httpd-healthcheck-nodeport
Namespace:                cka
Labels:                   run=httpd-healthcheck-nodeport
Annotations:              <none>
Selector:                 run=httpd-healthcheck-nodeport
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.97.138.226
IPs:                      10.97.138.226
Port:                     <unset>  10001/TCP
TargetPort:               10001/TCP
NodePort:                 <unset>  30080/TCP
Endpoints:                10.244.1.48:10001
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>

curl http://10.11.1.40:30080/
httpd-healthcheck
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-healthcheck-nodeport
  name: httpd-healthcheck-nodeport
  namespace: cka
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-healthcheck-nodeport
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: httpd-healthcheck-nodeport
  name: httpd-healthcheck-nodeport
  namespace: cka
spec:
  ports:
  - port: 10001
    protocol: TCP
    targetPort: 10001
    nodePort: 30080
  selector:
    run: httpd-healthcheck-nodeport
  type: NodePort
```

**Exercise 2**: perform the following tasks.

1. Create a pod `httpd-healthcheck-loadbalancer` that uses `lisenet/httpd-healthcheck:1.0.0` image.
2. Expose the pod's port 10001 through a service of type `LoadBalancer`.
3. Verify that the service has an external IP pending.

Imperative commands:

```bash
kubectl run httpd-healthcheck-loadbalancer --image=lisenet/httpd-healthcheck:1.0.0 -n cka

kubectl expose pod httpd-healthcheck-loadbalancer \
  --port=10001 --target-port=10001 --type=LoadBalancer -n cka

kubectl get svc/httpd-healthcheck-loadbalancer -n cka
NAME                             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
httpd-healthcheck-loadbalancer   LoadBalancer   10.111.116.18   <pending>     10001:32465/TCP   68s
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-healthcheck-loadbalancer
  name: httpd-healthcheck-loadbalancer
  namespace: cka
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-healthcheck-loadbalancer
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: httpd-healthcheck-loadbalancer
  name: httpd-healthcheck-loadbalancer
  namespace: cka
spec:
  ports:
  - port: 10001
    protocol: TCP
    targetPort: 10001
  selector:
    run: httpd-healthcheck-loadbalancer
  type: LoadBalancer
```

**Exercise 3**: perform the following tasks.

Imperative commands:

1. Follow up from the previous exercise 2 and deploy `MetalLB` to the cluster.
2. Verify that the service `httpd-healthcheck-loadbalancer` has an external IP address assigned.
3. Get the index page through the `LoadBalancer` service using `curl`.

```bash
kubectl create ns metallb-system

cat > metallb-configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.11.1.61-10.11.1.65
EOF

kubectl apply -f metallb-configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

kubectl get svc/httpd-healthcheck-loadbalancer -n cka
NAME                             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
httpd-healthcheck-loadbalancer   LoadBalancer   10.111.116.18   10.11.1.61    10001:32465/TCP   10m

curl http://10.11.1.61:10001
httpd-healthcheck
```

### Know how to use Ingress controllers and Ingress resources

Docs: https://kubernetes.io/docs/concepts/services-networking/ingress/

You must have an Ingress controller to satisfy an Ingress. Only creating an Ingress resource has no effect.

Docs: https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/

**Exercise**: perform the following tasks.

0. Make sure that you have `MetalLB` installed from the previous task.
1. Create a deployment object `httpd-pii-demo-blue` containing a single `lisenet/httpd-pii-demo:0.2` container and expose its port `80` through a type `LoadBalancer` service.
2. Create a deployment object `httpd-pii-demo-green` containing a single `lisenet/httpd-pii-demo:0.3` container and expose its port `80` through a type `LoadBalancer` service.
3. Deploy `ingress-nginx` controller.
4. Create the ingress resource `ingress-blue-green` to make the applications available at `/blue` and `/green` on the `Ingress` service.

Imperative commands:

```bash
kubectl create deploy httpd-pii-demo-blue --image=lisenet/httpd-pii-demo:0.2 -n cka
kubectl expose deploy/httpd-pii-demo-blue --port=80 --target-port=80 --type=LoadBalancer -n cka

kubectl create deploy httpd-pii-demo-green --image=lisenet/httpd-pii-demo:0.3 -n cka
kubectl expose deploy/httpd-pii-demo-green --port=80 --target-port=80 --type=LoadBalancer -n cka

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml

kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.107.59.72    10.11.1.62    80:30811/TCP,443:31972/TCP   51s
ingress-nginx-controller-admission   ClusterIP      10.100.251.17   <none>        443/TCP                      52s
```

Create a manifest file `ingress-blue-green.yaml` for an ingress resource:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-blue-green
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  namespace: cka
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /blue
        pathType: Prefix
        backend:
          service:
            name: httpd-pii-demo-blue
            port:
              number: 80
      - path: /green
        pathType: Prefix
        backend:
          service:
            name: httpd-pii-demo-green
            port:
              number: 80
```

Deploy ingress resource and verify:

```bash
kubectl apply -f ingress-blue-green.yaml

kubectl describe ingress/ingress-blue-green -n cka
Name:             ingress-blue-green
Namespace:        cka
Address:          10.11.1.62
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /blue    httpd-pii-demo-blue:80 (10.244.1.61:80)
              /green   httpd-pii-demo-green:80 (10.244.1.62:80)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    12s (x2 over 33s)  nginx-ingress-controller  Scheduled for sync
```

### Know how to configure and use CoreDNS

Docs: https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/

As of Kubernetes v1.12, CoreDNS is the recommended DNS Server, replacing kube-dns.

**Exercise**: perform the following tasks.

1. Create a pod `busybox` that uses `busybox` image and run the following command `sleep 7200`.
2. Exec a command in the container to show what nameservers have been configured in `/etc/resolv.conf`.
3. Exec a command in the container to perform `nslookup` on service `httpd-healthcheck-loadbalancer`.
4. Verify that the IP address returned matches with the service IP reported by Kubernetes.
5. Update coredns configmap to `forward` queries that are not within the cluster domain of Kubernetes to `10.11.1.2` and `10.11.1.3`. 
6. Exec a command in the container to perform `nslookup` on service `kubelb.hl.test`.

Imperative commands:

```bash
kubectl -n cka run busybox --image=busybox -- sleep 7200

kubectl -n cka exec busybox  -- cat /etc/resolv.conf
search cka.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
```

Execute `nslookup` command and check with the service to make sure the IPs match.

```bash
kubectl -n cka exec busybox -- nslookup httpd-healthcheck-loadbalancer
Server:		10.96.0.10
Address:	10.96.0.10:53

Name:	httpd-healthcheck-loadbalancer.cka.svc.cluster.local
Address: 10.111.116.18
```

```bash
kubectl -n cka get svc/httpd-healthcheck-loadbalancer
NAME                             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
httpd-healthcheck-loadbalancer   LoadBalancer   10.111.116.18   10.11.1.61    10001:32465/TCP   11h
```

Update coredns configmap and delete pods to pick up changes:

```bash
kubectl edit cm/coredns -n kube-system

for i in $(kubectl get po -n kube-system -l k8s-app=kube-dns -o name); do
  kubectl delete ${i} -n kube-system;
done

kubectl get cm/coredns -o yaml -n kube-system
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . 10.11.1.2 10.11.1.3 /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system

kubectl -n cka exec busybox -- nslookup kubelb.hl.test
Server:		10.96.0.10
Address:	10.96.0.10:53

Name:	kubelb.hl.test
Address: 10.11.1.30
```

### Choose an appropriate container network interface plugin

Docs: https://kubernetes.io/docs/concepts/cluster-administration/networking/

* **AWS VPC CNI** offers integrated AWS Virtual Private Cloud (VPC) networking for Kubernetes clusters.
* **Calico** is an open source networking and network security solution for containers, virtual machines, and native host-based workloads.
* **Flannel** is a very simple overlay network that satisfies the Kubernetes requirements.
* **Weave Net** is a resilient and simple to use network for Kubernetes and its hosted applications.

## Storage

Unless stated otherwise, all Kubernetes resources should be created in the `cka` namespace.

### Understand storage classes, persistent volumes

Docs:
* https://kubernetes.io/docs/concepts/storage/storage-classes/
* https://kubernetes.io/docs/concepts/storage/persistent-volumes/

**Exercise**: perform the following tasks.

1. Create a `storageclass` object named `portworx-csi` with the following specifications:
    * Provisioner is set to `kubernetes.io/portworx-volume`.
    * Reclaim policy is set to `Delete`.
    * Filesystem type `fs` is set to `xfs`.
    * Volume expansion is allowed.
2. Create a `persistentvolume` named `portworx-volume` based on this storage class with the following specifications:
    * Storage class name is set to `portworx-csi`.
    * Access mode is set to `ReadWriteOnce`.
    * Storage capacity is set to `100Mi`.
    * Persistent volume reclaim policy is set to `Delete`.
    * Volume mode is set to `Filesystem`.
3. Note, the `persistentvolume` will not initialise unless Portworx integration is configured, but the goal here is to get the YAML right.

Imperative commands:

```bash
cat > storageclass.yaml <<EOF
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: portworx-csi
provisioner: kubernetes.io/portworx-volume
parameters:
  fs: xfs
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
EOF

kubectl apply -f storageclass.yaml
```

```bash
kubectl get storageclass
NAME              PROVISIONER                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
portworx-csi      kubernetes.io/portworx-volume   Delete          Immediate           true                   5s
```

```bash
cat > persistentvolume.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: portworx-volume
spec:
  capacity:
    storage: 100Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: portworx-csi
EOF

kubectl apply -f persistentvolume.yaml
```

### Understand volume mode, access modes and reclaim policies for volumes

Docs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

Kubernetes supports two `volumeModes` of `PersistentVolumes`:
* **Filesystem** - volume with is mounted into Pods into a directory.
* **Block** - volume is presented into a Pod as a block device, without any filesystem on it.

Access modes:
* **ReadWriteOnce (RWO)** - the volume can be mounted as read-write by a single node.
* **ReadOnlyMany (ROX)** - the volume can be mounted as read-only by many nodes.
* **ReadWriteMany (RWX)** - the volume can be mounted as read-write by many nodes.
* **ReadWriteOncePod (RWOP)** - the volume can be mounted as read-write by a single Pod. Only supported for CSI volumes and Kubernetes version 1.22+.

Reclaim policies:
* **Retain** - manual reclamation.
* **Recycle** - basic scrub (`rm -rf /thevolume/*`). Currently, only NFS and HostPath support recycling.
* **Delete** - associated storage asset such as AWS EBS volume is deleted.

### Understand persistent volume claims primitive

A `PersistentVolume` is a piece of storage in the cluster that has been either provisioned by an administrator, or dynamically provisioned using `Storage Classes`.

A `PersistentVolumeClaim` is a **request for storage** by a user. For example, Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes.

Pods access storage by using the claim as a volume. Claims must exist in the same namespace as the Pod using the claim. The cluster finds the claim in the Pod's namespace and uses it to get the PersistentVolume backing the claim. The volume is then mounted to the host and into the Pod.

### Know how to configure applications with persistent storage

Docs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes

**Exercise**: perform the following tasks.

1. Create a persistent volume named `pv-httpd-webroot` with the following specifications:
    * Storage class name is set to `manual`.
    * Access mode is set to `ReadWriteMany`.
    * Storage capacity is set to `64Mi`.
    * Persistent volume reclaim policy is set to `Retain`.
    * Volume mode is set to `Filesystem`.
    * `hostPath` is set to `/mnt/data`.
2. Create a persistent volume claim object `pvc-httpd-webroot`.
3. Create a deployment object `httpd-persistent` consisting of 2 pods, each containing a single `httpd:2.4` container.
4. Configure deployment to use the persistent volume claim as a volume where `mountPath` is set to `/usr/local/apache2/htdocs`.
5. Exec a command in either of the httpd containers and create a blank file `/usr/local/apache2/htdocs/blank.html`.
6. Delete the deployment object `httpd-persistent`.
7. Create the deployment object `httpd-persistent` again.
8. Exec a command in either of the httpd containers to verify that the file `/usr/local/apache2/htdocs/blank.html` exists.

Imperative commands:

```bash
cat > pv-httpd-webroot.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-httpd-webroot
spec:
  capacity:
    storage: 64Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/mnt/data"
EOF

kubectl apply -f pv-httpd-webroot.yaml
```

```bash
kubectl get pv
NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv-httpd-webroot   64Mi       RWX            Retain           Available           manual                  15s
```
```
cat > pvc-httpd-webroot.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-httpd-webroot
  namespace: cka
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 64Mi
EOF

kubectl apply -f pvc-httpd-webroot.yaml
```

```bash
kubectl get pvc -n cka
NAME                STATUS   VOLUME             CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-httpd-webroot   Bound    pv-httpd-webroot   64Mi       RWX            manual         8s
```

```bash
kubectl create deploy httpd-persistent \
  --image=httpd:2.4 --replicas=2 \
  --dry-run=client -o yaml -n cka > httpd-persistent.yaml
```

Edit the file `httpd-persistent.yaml` and add `volumes` and `volumeMounts` sections:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: httpd-persistent
  name: httpd-persistent
  namespace: cka
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd-persistent
  template:
    metadata:
      labels:
        app: httpd-persistent
    spec:
      containers:
      - image: httpd:2.4
        name: httpd
        volumeMounts:
          - mountPath: "/usr/local/apache2/htdocs"
            name: pvc-httpd-persistent
      volumes:
      - name: pvc-httpd-persistent
        persistentVolumeClaim:
          claimName: pvc-httpd-webroot
```

Create deployment:

```bash
kubectl apply -f httpd-persistent.yaml
```

Create a blank file:

```bash
kubectl -n cka exec $(k get po -n cka | grep httpd-persistent | cut -d" " -f1 | head -n1) -- touch /usr/local/apache2/htdocs/blank.html
```

Delete and re-create the deployment:

```bash
kubectl delete deploy/httpd-persistent -n cka
kubectl apply -f httpd-persistent.yaml
```

Verify the blank file exists:

```bash
kubectl -n cka exec $(k get po -n cka | grep httpd-persistent | cut -d" " -f1 | head -n1) -- ls /usr/local/apache2/htdocs/blank.html
/usr/local/apache2/htdocs/blank.html
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-httpd-webroot
spec:
  capacity:
    storage: 64Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-httpd-webroot
  namespace: cka
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 64Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: httpd-persistent
  name: httpd-persistent
  namespace: cka
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd-persistent
  template:
    metadata:
      labels:
        app: httpd-persistent
    spec:
      containers:
      - image: httpd:2.4
        name: httpd
        volumeMounts:
          - mountPath: "/usr/local/apache2/htdocs"
            name: pvc-httpd-persistent
      volumes:
      - name: pvc-httpd-persistent
        persistentVolumeClaim:
          claimName: pvc-httpd-webroot
```

## Troubleshooting

### Evaluate cluster and node logging

Display addresses of the master and services:

```bash
kubectl cluster-info
```

Show the latest events in the whole cluster, ordered by time (see `kubectl` cheatsheet documentation):

```bash
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

Check the status of the nodes:

```bash
kubectl get nodes
```

Check the status of the Docker service:

```bash
systemctl status docker
```

View `kubelet` systemd service logs:

```bash
journalctl -u kubelet
```

Check etcd health and status:

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
    endpoint health
https://127.0.0.1:2379 is healthy: successfully committed proposal: took = 12.882378ms


ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
    endpoint status
https://127.0.0.1:2379, 9dc11d4117b1b759, 3.5.0, 4.7 MB, true, 3, 561317
```

### Understand how to monitor applications

Dump pod logs to stdout:

```bash
kubectl logs ${POD_NAME}   
```

Dump pod logs for a deployment (single-container case):

```bash
kubectl logs deploy/${DEPLOYMENT_NAME}
```

Dump pod logs for a deployment (multi-container case):

```bash
kubectl logs deploy/${DEPLOYMENT_NAME} -c ${CONTAINER_NAME}
```

### Manage container stdout and stderr logs

We can write container logs to a file. For example, get container ID of coredns:

```bash
crictl ps --quiet --name coredns 
5582a4b80318a741ad0d9a05df6d235642e73a2e88ff53933c103ffd854c0069
```

Dump container logs to a file (both the standard output and standard error):

```bash
crictl logs ${CONTAINER_ID} > ./container.log 2>&1
```

### Troubleshoot application failure

Docs: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/

Depends on the application. The first step in debugging a pod is taking a look at it. Check the current state of the pod and recent events with the following command:

```bash
kubectl describe pods ${POD_NAME}
```

### Troubleshoot cluster component failure

Docs: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/

Check log files:

* `/var/log/kube-apiserver.log`
* `/var/log/kube-scheduler.log`
* `/var/log/kube-controller-manager.log`
* `/var/log/kubelet.log`
* `/var/log/kube-proxy.log`

### Troubleshoot networking

Docs: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/

Run commands in a pod. The `--rm` parameter deletes the pod after it exits.

```bash
kubectl run busybox --image=busybox --rm --restart=Never -it sh
```

Now you can run things like `nslookup`, `nc` or `telnet` into Mordor.

## Bonus Exercise: am I ready for the CKA exam?

If you can't solve this then you're likely **not** ready.

**Bonus exercise**: perform the following tasks to create a stateful application.

Docs: https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

1. Create a namespace called `cka`. All resources should be created in this namespace.
2. Create a new secret `mysql-password` that has the following key=value pair:
    * `mysql_root_password` = Mysql5.6Password
3. Create a new `PersistentVolume` named `pv-mysql`.
    * Set capacity to `1Gi`.
    * Set `accessMode` to `ReadWriteOnce`.
    * Set `hostPath` to `/data_mysql`.
    * Set `persistentVolumeReclaimPolicy` to `Recycle`.
    * The volume should have no `storageClassName` defined.
4. Create a new `PersistentVolumeClaim` named `pvc-mysql`. It should request `1Gi` storage, accessMode `ReadWriteOnce` and should not define a `storageClassName`. The PVC should bound to the PV correctly.
5. Create a new `StatefulSet` named `mysql`.
    * Use container image `mysql:5.6`.
    * The container in the pod should `runAsUser=65534` and `runAsGroup=65534`.
    * Mount the persistent volume at `/var/lib/mysql`.
    * There should be only `1 replica` running.
    * Define `initContainer` called `fix-permissions` that uses image `busybox:1.35`.
    * The `initContainer` should `runAsUser=0`.
    * The `initContainer` should to mount the persistent volume and run the following command: `["sh", "-c", "chown -R 65534:65534 /var/lib/mysql"]`.
6. Configure `mysql` stateful set deployment so that the underlying container has the following environment variables set:
    * `MYSQL_ROOT_PASSWORD` from secret key `mysql_root_password`.
7. Create a new `ClusterIP` service named `mysql` which exposes `mysql` pods on port `3306`.
8. Create a new `Deployment` named `wordpress`.
    * Use container image `wordpress:4.8-apache`.
    * Use deployment strategy `Recreate`.
    * There should be `3 replicas` created.
    * The pods should request `10m` cpu and `64Mi` memory.
    * The `livenessProbe` should perform an HTTP GET request to the path `/readme.html` and port `80` every 5 seconds.
    * Configure `PodAntiAffinity` to ensure that the scheduler does not co-locate replicas on a single node.
    * Pods of this deployment should be able to run on master nodes as well, create the proper `toleration`.
9. Configure `wordpress` deployment so that the underlying container has the following environment variables set:
    * `WORDPRESS_DB_PASSWORD` from secret key `mysql_root_password`.
    * `WORDPRESS_DB_HOST` set to value of `mysql`.
10. Create a `NodePort` service named `wordpress` which exposes `wordpress` deployment on port `80` and connects to the container on port `80`. The port on the node should be set to `31234`.
11. Create a `NetworkPolicy` called `netpol-mysql`. Use the `app` label of pods in your policy. The policy should allow the `mysql-*` pods to:
    * accept ingress traffic on port `3306` from `wordpres-*` pods only.
    * connect to IP block `10.0.0.0/8`.
12. Navigate your web browser to http://${NODE_IP_ADDRESS}:31234/ and take a moment to enjoy a brand new instance of WordPress on Kubernetes.
13. Take a backup of `etcd` running on the control plane and save it on the control plane to `/tmp/etcd-backup.db`.
14. Delete `wordpress` deployment configuration from the cluster. Verify that the application is no longer accessible.
15. Restore `etcd` configuration from the backup file `/tmp/etcd-backup.db`. Confirm that the cluster is working and that all `wordpress` pods are back.

Imperative commands:

```bash
kubectl create ns cka

kubectl create secret generic mysql-password \
  --from-literal=mysql_root_password="Mysql5.6Password" -n cka

cat > pv-mysql.yaml <<EOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-mysql
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  persistentVolumeReclaimPolicy: Recycle
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data_mysql"
EOF

cat > pvc-mysql.yaml <<EOF
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-mysql
  namespace: cka
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
EOF

kubectl apply -f pv-mysql.yaml
kubectl apply -f pvc-mysql.yaml

kubectl create deploy mysql --image=mysql:5.6 --replicas=1 \
  --dry-run=client -o yaml -n cka > deployment-mysql.yaml
```

Edit the file `deployment-mysql.yaml`, change `Deployment` to `StatefulSet` and add required configuration:

```yaml
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: mysql
  name: mysql
  namespace: cka
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      securityContext:
        runAsUser: 65534
        runAsGroup: 65534
      volumes:
      - name: pv-mysql
        persistentVolumeClaim:
          claimName: pvc-mysql
      initContainers:
        - name: fix-permissions
          image: busybox:1.35
          command: ["sh", "-c", "chown -R 65534:65534 /var/lib/mysql"]
          securityContext:
            runAsUser: 0
          volumeMounts:
            - mountPath: "/var/lib/mysql"
              name: pv-mysql
      containers:
      - image: mysql:5.6
        name: mysql
        volumeMounts:
        - mountPath: "/var/lib/mysql"
          name: pv-mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-password
              key: mysql_root_password
```

Create the deployment and verify mysql pod logs:

```bash
kubectl apply -f deployment-mysql.yaml

kubectl logs $(kubectl get po -n cka -l app=mysql -o name) -n cka | tail -n1
Version: '5.6.51'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
```

Create a service for mysql, which serves on port 3306:

```bash
kubectl create svc clusterip mysql --tcp=3306 -n cka

kubectl get svc -n cka
NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
mysql   ClusterIP   10.107.189.130   <none>        3306/TCP   111s
```

Create a deplopyment file for wordpress.

```bash
kubectl create deploy wordpress --image=wordpress:4.8-apache --replicas=3 \
  --dry-run=client -o yaml -n cka > deployment-wordpress.yaml
```

Edit the file `deployment-wordpress.yaml` and add required configuration:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: wordpress
  name: wordpress
  namespace: cka
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    strategy:
      type: Recreate
    spec:
      # The deployment has PodAntiAffinity configured to ensure
      # the scheduler does not co-locate replicas on a single node.
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - wordpress
            topologyKey: "kubernetes.io/hostname"
      # The following toleration "matches" the taint on the master node, therefore
      # a pod with this toleration would be able to schedule onto master.
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-password
              key: mysql_root_password
        - name: WORDPRESS_DB_HOST
          value: mysql
        resources:
          requests:
            cpu: 10m
            memory: 64Mi
        livenessProbe:
          httpGet:
            path: /readme.html
            port: 80
          periodSeconds: 5
```

Create the deployment and verify wordpress pod logs:

```bash
kubectl apply -f deployment-wordpress.yaml

kubectl logs $(kubectl get po -n cka -l app=wordpress -o name|head -n1) -n cka | grep WordPress
WordPress not found in /var/www/html - copying now...
Complete! WordPress has been successfully copied to /var/www/html
```

While the wordpress pods can run on both the worker and master nodes because of `tolerations`, we only have one of each (single master and single worker node), meaning that the 3rd replica of wordpress cannot be scheduled and will be in a pending state.

Create a service for wordpress, which serves on port 80 and connects to the containers on port 80:

```bash
kubectl expose deployment wordpress --type=NodePort --port=80 --target-port=80 \
  --dry-run=client -o yaml -n cka > service-wordpress.yaml
```

Edit the file `service-wordpress.yaml` and add `nodePort`:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: wordpress
  name: wordpress
  namespace: cka
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 31234
  selector:
    app: wordpress
  type: NodePort
```

Create the service and verify:

```bash
kubectl apply -f service-wordpress.yaml

kubectl get svc -n cka
NAME        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
mysql       ClusterIP   10.107.189.130   <none>        3306/TCP       20m
wordpress   NodePort    10.110.61.109    <none>        80:31234/TCP   20m
```

Create a file `netpol-wordpress.yaml` that contains our network policy configuration:

```bash
cat > netpol-mysql.yaml <<EOF
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: netpol-mysql
  namespace: cka
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: wordpress
      ports:
      - protocol: TCP
        port: 3306
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
EOF
```

Deploy the network policy:

```bash
kubectl apply -f netpol-mysql.yaml
```

Now, navigate your browser to **http://{NODE_IP_ADDRESS}:31234/** and enjoy a brand new instance of WordPress on Kubernetes.

Take an `etcd` snapshot on the control plane by specifying the endpoint and certificates:

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db
```

Delete wordpress deployment:

```bash
kubectl delete deploy/wordpress -n cka
```

No wordpress pods should be present at this point.

Restore `etcd` configuration from the snapshot. On the control plane, identify the default `data-dir`:

```bash
grep data-dir /etc/kubernetes/manifests/etcd.yaml
    - --data-dir=/var/lib/etcd
```

Stop all control plane components:

```bash
cd /etc/kubernetes/manifests/
mv ./*yaml ../
```

Make sure that all control plane pods are `NotReady`:

```bash
crictl pods | egrep "kube|etcd"
```

Restore the snapshot to directory `/var/lib/etcd_backup`:

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --data-dir /var/lib/etcd_backup \
  snapshot restore /tmp/etcd-backup.db
```

Configure etcd to use the new directory `/var/lib/etcd_backup`:

```bash
sed -i 's/\/var\/lib\/etcd/\/var\/lib\/etcd_backup/g' /etc/kubernetes/manifests/etcd.yaml
```

Start all control plane components:

```bash
cd /etc/kubernetes/manifests/
mv ../*yaml ./
```

Give it some time (up to several minutes) for etcd to restart, and verify that wordpress pods are back.

```bash
kubectl get po -n cka
NAME                        READY   STATUS    RESTARTS   AGE
mysql-0                     1/1     Running   0          40m
wordpress-c7b5c7666-bntkc   1/1     Running   0          38s
wordpress-c7b5c7666-djrzl   0/1     Pending   0          38s
wordpress-c7b5c7666-lf6l7   1/1     Running   0          38s
```

For declarative YAML solution, see [bonus-task-solution.yaml](./yaml/bonus-task-solution.yaml).
