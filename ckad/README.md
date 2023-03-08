# Certified Kubernetes Application Developer (CKAD)

Preparation and study material for Certified Kubernetes Application Developer exam v1.26.

- [Reasoning](#reasoning)
- [Aliases](#aliases)
- [Allowed Kubernetes documentation resources](#allowed-kubernetes-documentation-resources)
- [CKAD Environment](#ckad-environment)
- [CKAD Exam Simulator](#ckad-exam-simulator)
- [Prep: Cluster Installation and Configuration](#prep-cluster-installation-and-configuration)
    - [Provision underlying infrastructure to deploy a Kubernetes cluster](#provision-underlying-infrastructure-to-deploy-a-kubernetes-cluster)
    - [Use Kubeadm to install a basic cluster](#use-kubeadm-to-install-a-basic-cluster)
- [Prep: Install Podman and Helm](#prep-install-podman-and-helm)
- [Application Design and Build](#application-design-and-build)
    - [Define, build and modify container images](#define-build-and-modify-container-images)
        - [Task 1](#task-1)
        - [Solution 1](#solution-1)
        - [Task 2](#task-2)
        - [Solution 2](#solution-2)
    - [Understand Jobs and CronJobs](#understand-jobs-and-cronjobs)
        - [Task 3](#task-3)
        - [Solution 3](#solution-3)
        - [Task 4](#task-4)
        - [Solution 4](#solution-4)
    - [Understand multi-container Pod design patterns (sidecar, init and others)](#understand-multi-container-pod-design-patterns-sidecar-init-and-others)
        - [Task 5](#task-5)
        - [Solution 5](#solution-5)
    - [Utilise persistent and ephemeral volumes](#utilise-persistent-and-ephemeral-volumes)
        - [Task 6](#task-6)
        - [Solution 6](#solution-6)
- [Application Deployment](#application-deployment)
    - [Use Kubernetes primitives to implement common deployment strategies (blue/green or canary)](#use-kubernetes-primitives-to-implement-common-deployment-strategies-bluegreen-or-canary)
        - [Task 7: Blue/Green Deployment](#task-7-bluegreen-deployment)
        - [Solution 7](#solution-7)
        - [Task 8: Canary Deployment](#task-8-canary-deployment)
        - [Solution 8](#solution-8)
    - [Understand Deployments and how to perform rolling updates](#understand-deployments-and-how-to-perform-rolling-updates)
        - [Task 9](#task-9)
        - [Solution 9](#solution-9)
    - [Use the Helm package manager to deploy existing packages](#use-the-helm-package-manager-to-deploy-existing-packages)
        - [Task 10](#task-10)
        - [Solution 10](#solution-10)
- [Application Observability and Maintenance](#application-observability-and-maintenance)
    - [Understand API deprecations](#understand-api-deprecations)
        - [Task 11](#task-11)
        - [Solution 11](#solution-11)
    - [Implement probes and health checks](#implement-probes-and-health-checks)
        - [Task 12](#task-12)
        - [Solution 12](#solution-12)
    - [Use provided tools to monitor Kubernetes applications](#use-provided-tools-to-monitor-kubernetes-applications)
    - [Utilise container logs](#utilise-container-logs)
    - [Debugging in Kubernetes](#debugging-in-kubernetes)
- [Application Environment, Configuration and Security](#application-environment-configuration-and-security)
    - [Discover and use resources that extend Kubernetes (CRD)](#discover-and-use-resources-that-extend-kubernetes-crd)
        - [Task 13](#task-13)
        - [Solution 13](#solution-13)
    - [Understand authentication, authorisation and admission control](#understand-authentication-authorisation-and-admission-control)
    - [Understanding and defining resource requirements, limits and quotas](#understanding-and-defining-resource-requirements-limits-and-quotas)
        - [Task 14](#task-14)
        - [Solution 14](#solution-14)
        - [Task 15](#task-15)
        - [Solution 15](#solution-15)
    - [Understand ConfigMaps](#understand-configmaps)
        - [Task 16](#task-16)
        - [Solution 16](#solution-16)
        - [Task 17](#task-17)
        - [Solution 17](#solution-17)
    - [Create and consume Secrets](#create-and-consume-secrets)
        - [Task 18](#task-18)
        - [Solution 18](#solution-18)
    - [Understand ServiceAccounts](#understand-serviceaccounts)
        - [Task 19](#task-19)
        - [Solution 19](#solution-19)
    - [Understand SecurityContexts](#understand-securitycontexts)
        - [Task 20](#task-20)
        - [Solution 20](#solution-20)
- [Services and Networking](#services-and-networking)
    - [Demonstrate basic understanding of NetworkPolicies](#demonstrate-basic-understanding-of-networkpolicies)
        - [Task 21](#task-21)
        - [Solution 21](#solution-21)
    - [Provide and troubleshoot access to applications via services](#provide-and-troubleshoot-access-to-applications-via-services)
        - [Task 22](#task-22)
    - [Use Ingress rules to expose applications](#use-ingress-rules-to-expose-applications)
        - [Task 23](#task-23)
        - [Solution 23](#solution-23)

## Reasoning

Having passed CKA earlier, it only makes sense to go for CKAD and CKS.

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
* [Helm Documentation](https://helm.sh/docs)

## CKAD Environment

See https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad#cka-and-ckad-environment

There are four clusters (CKAD) that comprise the exam environment, made up of varying numbers of containers, as follows:

Cluster | Members | CNI | Description
--- | --- | --- | ---
k8s | 1 master, 2 worker | flannel | k8s cluster
dk8s | 1 master, 1 worker | flannel | k8s cluster
nk8s | 1 master, 2 worker | calico | k8s cluster
sk8s | 1 master, 1 worker | flannel | k8s cluster

At the start of each task you'll be provided with the command to ensure you are on the correct cluster to complete the task.

Command-like tools `kubectl`, `jq`, `tmux`, `curl`, `wget` and `man` are pre-installed in all environments.

## CKAD Exam Simulator

https://killer.sh/ckad

Do not sit the CKAD exam unless you get the perfect score **and** understand the solutions (regardless of the time taken to solve all questions).

![CKAD Simulator](./images/killer-shell-ckad-simulator.png)

## Prep: Cluster Installation and Configuration

**This section is not part of CKAD exam objectives**, however, we need to build a Kubernetes cluster to practise on.

### Provision underlying infrastructure to deploy a Kubernetes cluster

We have a [six-node](../docs/kubernetes-homelab-diagram.png) (three control planes and three worker nodes) Kubernetes homelab cluster running [Rocky Linux](https://www.lisenet.com/2021/migrating-ha-kubernetes-cluster-from-centos-7-to-rocky-linux-8/) already.

For the purpose of our CKAD studies, we will create a new two-node cluster, with one control plane and one worker node, using Ubuntu 20.04 LTS. It makes sense to use a Debian-based distribution here because we have a RHEL-based homelab cluster already.

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

![PXE boot menu](../docs/homelab-pxe-boot-menu.png)

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

We will use `kubeadm` to install a Kubernetes v1.26 cluster.

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

Install `kubeadm`, `kubelet` and `kubectl` (v1.26):

```bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.26.1-00 kubeadm=1.26.1-00 kubectl=1.26.1-00
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
```

Docs: https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

Initialise the **control plane** node. Set pod network CIDR based on the CNI that you plan to install later:

* Calico - `192.168.0.0/16`
* Flannel - `10.244.0.0/16`
* Weave Net - `10.32.0.0/12`

We are going to use Calico to support network policies, hence `192.168.0.0/16`.

```bash
sudo kubeadm init \
  --kubernetes-version "1.26.1" \
  --pod-network-cidr "192.168.0.0/16"
```

Configure `kubectl` access on the **control plane**:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Run the output of the init command on the **worker node**:

```bash
kubeadm join 10.11.1.37:6443 --token e3mo9r.tul2hff2tx3ykkj7 \
  --discovery-token-ca-cert-hash sha256:8048cdef7090a3dec68ffe83fc329111a2efb83523ec659e0e9d5d4ebb2d19f7
```

Install a pod network to the cluster. To install Calico, run the following:

```bash
kubectl apply -f kubectl apply -f "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
```

Check the cluster to make sure that all nodes are running and ready:

```bash
kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
srv37   Ready    control-plane   18h   v1.26.1   10.11.1.37    <none>        Ubuntu 20.04.5 LTS   5.4.0-139-generic   containerd://1.6.18
srv38   Ready    <none>          18h   v1.26.1   10.11.1.38    <none>        Ubuntu 20.04.5 LTS   5.4.0-139-generic   containerd://1.6.18
```

Now that we have a cluster running, we can start with the exam objectives.

## Prep: Install Podman and Helm

While installation of these tools is not part of the CKAD exam objectives, we are going to need to have them on our system in order to solve tasks.

Use these commands to install Podman on Ubuntu 20.04:

```bash
VERSION_ID="20.04"
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get install -y podman
```

Use these commands to install Helm on Ubuntu 20.04:

```bash
sudo apt install -y apt-transport-https software-properties-common
curl -fsSL https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo add-apt-repository -y "deb https://baltocdn.com/helm/stable/debian/ all main"
sudo apt-get update -qq
sudo apt-get install -y helm
```

## Application Design and Build

Unless stated otherwise, all Kubernetes resources should be created in the `ckad` namespace.

### Define, build and modify container images

Study material for this section is very similar to that of the [Red Hat's EX180 exam](https://github.com/lisenet/RHCA-study-notes/blob/master/EX180_study_notes.md) that I had taken previously.

Before you start with this section, please log in to Red Hat Developer portal and download the **jboss-eap-7.4.0.zip** file to your working directory. See the weblink below, do note that it requires a free Red Hat account:

https://developers.redhat.com/content-gateway/file/jboss-eap-7.4.0.zip

Also create a Docker Hub account if you don't have one.

#### Task 1

As a certified application developer, you should be able to define and build container images. Write a `Dockerfile` to containerise a JBoss EAP 7.4 application to meet all of the following requirements (listed in no particular order):

1. Use tag `8.7` of Red Hat Universal Base Image 8 `ubi8` from the Docker Hub registry `docker.io/redhat` as a base.
2. Install the `java-1.8.0-openjdk-devel` package.
3. Create a system group for `jboss` with a GID of 1100.
4. Create a system user for `jboss` with a UID 1100.
5. Set the jboss user’s home directory to `/opt/jboss`.
6. Set the working directory to jboss user's home directory.
7. Recursively change the ownership of the jboss user’s home directory to `jboss:jboss`.
8. Expose port `8080`.
9. Make the container run as the `jboss` user.
10. Unpack the `jboss-eap-7.4.0.zip` file to the `/opt/jboss` directory.
11. Set the environment variable `JBOSS_HOME` to `/opt/jboss/jboss-eap-7.4`.
12. Start container with the following executable: `/opt/jboss/jboss-eap-7.4/bin/standalone.sh -b 0.0.0.0 -c standalone-full-ha.xml`.

#### Solution 1

This is how the Dockerfile should look like. Comments are provided for references.

```ini
# Use base image
FROM docker.io/redhat/ubi8:8.7

# Install the java-1.8.0-openjdk-devel package
# We also need the unzip package to unpack the JBoss .zip archive
RUN yum install -y java-1.8.0-openjdk-devel unzip && yum clean all

# Create a system user and group for jboss, they both have a UID and GID of 1100
# Set the jboss user's home directory to /opt/jboss
RUN groupadd -r -g 1100 jboss && useradd -u 1100 -r -m -g jboss -d /opt/jboss -s /sbin/nologin jboss

# Set the environment variable JBOSS_HOME to /opt/jboss/jboss-eap-7.4.0
ENV JBOSS_HOME="/opt/jboss/jboss-eap-7.4"

# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

# Unpack the jboss-eap-7.4.0.zip file to the /opt/jboss directory
ADD ./jboss-eap-7.4.0.zip /opt/jboss
RUN unzip /opt/jboss/jboss-eap-7.4.0.zip

# Recursively change the ownership of the jboss user's home directory to jboss:jboss
# Make sure to RUN the chown after the ADD command and before it, as ADD will
# create new files and directories with a UID and GID of 0 by default
RUN chown -R jboss:jboss /opt/jboss

# Make the container run as the jboss user
USER jboss

# Expose JBoss port
EXPOSE 8080

# Start JBoss, use the exec form which is the preferred form
ENTRYPOINT ["/opt/jboss/jboss-eap-7.4/bin/standalone.sh", "-b", "0.0.0.0", "-c", "standalone-full-ha.xml"]
```

#### Task 2

Build the container image using Podman from the `Dockerfile` you have created in [task 1](#task-1).

1. Name the image as `ckadstudy-jboss-eap`, add a tag of `7.4.0-podman`, and push the image to your Docker Hub's registry account.
2. Also tag the images as `latest` and push to Docker Hub.
3. Use Podman to run a container named `jboss-from-dockerfile`, which keeps running in the background, using image `ckadstudy-jboss-eap:7.4.0-podman`. Run the container as a regular user and not as root. Expose container port `8080`.
4. Write logs of the container `jboss-from-dockerfile` to file `/tmp/jboss-from-dockerfile.log`.

#### Solution 2

Imperative commands.

Make sure that the file `jboss-eap-7.4.0.zip` has been downloaded and is in the working directory:

```bash
ls -1
Dockerfile
jboss-eap-7.4.0.zip
```

Build the image:

```bash
podman build -t ckadstudy-jboss-eap:7.4.0-podman -t ckadstudy-jboss-eap:latest .
```

View all local images:

```bash
podman images
REPOSITORY                     TAG           IMAGE ID      CREATED             SIZE
localhost/ckadstudy-jboss-eap  7.4.0-podman  d0e3daccd5d3  About a minute ago  1.44 GB
localhost/ckadstudy-jboss-eap  latest        d0e3daccd5d3  About a minute ago  1.44 GB
docker.io/redhat/ubi8          8.7           270f760d3d04  2 weeks ago         214 MB
```

Tag the images, log into Docker Hub registry and then push the images to it:

```bash
podman tag localhost/ckadstudy-jboss-eap:7.4.0-podman lisenet/ckadstudy-jboss-eap:7.4.0-podman
podman tag localhost/ckadstudy-jboss-eap:latest lisenet/ckadstudy-jboss-eap:latest
```

```bash
podman login docker.io
```

```bash
podman push lisenet/ckadstudy-jboss-eap:7.4.0-podman
podman push lisenet/ckadstudy-jboss-eap:latest
```

Run a container and expose port `8080`:

```bash
podman run -d --name jboss-from-dockerfile -p 8080:8080 localhost/ckadstudy-jboss-eap:7.4.0-podman
```

```bash
podman ps
CONTAINER ID  IMAGE                                       COMMAND     CREATED         STATUS             PORTS                   NAMES
0ad455a21fa2  localhost/ckadstudy-jboss-eap:7.4.0-podman              40 seconds ago  Up 40 seconds ago  0.0.0.0:8080->8080/tcp  jboss-from-dockerfile
```

Verify the port is accessible:

```bash
curl -s 127.0.0.1:8080 | grep Welcome
    <title>Welcome to JBoss EAP 7</title>
      <h1>Welcome to JBoss EAP 7</h1>
```

Write logs to `/tmp/jboss-from-dockerfile.log` file:

```bash
podman logs jboss-from-dockerfile | tee /tmp/jboss-from-dockerfile.log
```

### Understand Jobs and CronJobs

Docs:
* https://kubernetes.io/docs/concepts/workloads/controllers/job/
* https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

#### Task 3

1. Create a `job` called `pi` in `ckad` namespace.
2. This job should run image `perl:5.34.0` and execute command `["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]`.
3. It should run a total of 8 times and should execute 2 runs in parallel.
4. Set `restartPolicy` to `Never`.

#### Solution 3

Imperative commands. Create a job template:

```bash
kubeclt create job pi --image=perl:5.34.0 \
  --dry-run=client -o yaml -n ckad > pi-job.yaml
```

Edit the file `pi-job.yaml` and add missing resources:

```yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
  namespace: ckad
spec:
  completions: 8
  parallelism: 2
  template:
    spec:
      containers:
      - image: perl:5.34.0
        name: pi
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

Create the job:

```bash
kubectl apply -f pi-job.yaml
```

Verify:

```bash
kubectl get job -n ckad -o wide
NAME  COMPLETIONS   DURATION   AGE   CONTAINERS   IMAGES         SELECTOR
pi    2/8           17s        17s   pi           perl:5.34.0    controller-uid=adbaa84e
```

#### Task 4

1. Create a `cronjob` called `crondate` in `ckad` namespace.
2. This job should run image `busybox:1.35` and execute command `date` every 2 minutes.
3. Set `successfulJobsHistoryLimit` to 5 and `failedJobsHistoryLimit` to 3.
4. Set `concurrencyPolicy` to `Replace`.

#### Solution 4

Imperative commands. Create a job template:

```bash
kubectl create cronjob crondate --image=busybox:1.35 --schedule="*/2 * * * *" \
  --dry-run=client -o yaml -n ckad -- date > crondate.yaml
```

Edit the file `crondate.yaml` and add missing resources:

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: crondate
  namespace: ckad
spec:
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 3
  concurrencyPolicy: Replace
  jobTemplate:
    metadata:
      name: crondate
    spec:
      template:
        spec:
          containers:
          - command:
            - date
            image: busybox:1.35
            name: crondate
          restartPolicy: OnFailure
  schedule: '*/2 * * * *'
```

Create the cronjob:

```bash
kubectl apply -f crondate.yaml
```

Verify:

```bash
kubectl get cronjob -o wide -n ckad
NAME       SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE   CONTAINERS   IMAGES         SELECTOR
crondate   */2 * * * *   False     0        19s             83s   crondate     busybox:1.35   <none>
```

### Understand multi-container Pod design patterns (sidecar, init and others)

Docs:
* https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

#### Task 5

1. Create a pod called `web-multi-container` that has three containers (see below).
2. A container named `main` running `nginx:alpine` image. This container should expose port `80`.
3. A sidecar container named `sidecar-updater` running `busybox:1.35` image. The sidecar container run the following command: `["sh","-c","while true; do date | tee /usr/share/nginx/html/index.html; sleep 1; done"]`.
4. An `initContainer` named `init-health` running `busybox:1.35.0` image. The init container runs the following command: `["sh","-c","echo live > /usr/share/nginx/html/health"]`.
5. All containers inside the pod should mount an `emptyDir` volume named `webroot`, the mount path is `/usr/share/nginx/html`.

#### Solution 5

Imperative commands:

```bash
kubectl run web-multi-container --image=nginx:alpine --port=80 \
  --dry-run=client -o yaml -n ckad > web-multi-container.yaml
```

Edit the file `web-multi-container.yaml` and add an init container as well as a sidecar one, also add a volume.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: web-multi-container
  name: web-multi-container
  namespace: ckad
spec:
  volumes:
    - name: webroot
      emptyDir: {}
  containers:
  - image: nginx:alpine
    name: main
    ports:
    - containerPort: 80
    volumeMounts:
      - mountPath: /usr/share/nginx/html
        name: webroot
  - image: busybox:1.35
    name: sidecar-updater
    command: ["sh","-c","while true; do date | tee /usr/share/nginx/html/index.html; sleep 1; done"]
    volumeMounts:
      - mountPath: /usr/share/nginx/html
        name: webroot
  initContainers:
  - image: busybox:1.35
    name: init-health
    command: ["sh","-c","echo live > /usr/share/nginx/html/health"]
    volumeMounts:
      - mountPath: /usr/share/nginx/html
        name: webroot
```

Deploy the pod and verify that 2 containers are running:

```bash
kubectl apply -f web-multi-container.yaml
```

```bash
kubectl get po/web-multi-container -n ckad
NAME                  READY   STATUS    RESTARTS   AGE
web-multi-container   2/2     Running   0          2m15s
```

Also verify that webroot files have been created:

```bash
kubectl exec web-multi-container -c main -n ckad -- cat /usr/share/nginx/html/health
live
```

```bash
kubectl exec web-multi-container -c main -n ckad -- cat /usr/share/nginx/html/index.html
Tue Feb 28 20:20:52 UTC 2023
```

### Utilise persistent and ephemeral volumes

#### Task 6

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

#### Solution 6

Imperative commands:

```bash
cat > pv-httpd-webroot.yaml <<EOF
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
EOF
```

```bash
kubectl apply -f pv-httpd-webroot.yaml
```

```bash
kubectl get pv
NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv-httpd-webroot   64Mi       RWX            Retain           Available           manual                  15s
```

```bash
cat > pvc-httpd-webroot.yaml <<EOF
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-httpd-webroot
  namespace: ckad
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 64Mi
EOF
```

```bash
kubectl apply -f pvc-httpd-webroot.yaml
```

```bash
kubectl get pvc -n ckad
NAME                STATUS   VOLUME             CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-httpd-webroot   Bound    pv-httpd-webroot   64Mi       RWX            manual         8s
```

```bash
kubectl create deploy httpd-persistent \
  --image=httpd:2.4 --replicas=2 \
  --dry-run=client -o yaml -n ckad > httpd-persistent.yaml
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
  namespace: ckad
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
kubectl -n ckad exec $(k get po -n ckad | grep httpd-persistent | cut -d" " -f1 | head -n1) -- touch /usr/local/apache2/htdocs/blank.html
```

Delete and re-create the deployment:

```bash
kubectl delete deploy/httpd-persistent -n ckad
kubectl apply -f httpd-persistent.yaml
```

Verify the blank file exists:

```bash
kubectl -n ckad exec $(k get po -n ckad | grep httpd-persistent | cut -d" " -f1 | head -n1) -- ls /usr/local/apache2/htdocs/blank.html
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
  namespace: ckad
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
  namespace: ckad
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

## Application Deployment

Unless stated otherwise, all Kubernetes resources should be created in the `ckad` namespace.

### Use Kubernetes primitives to implement common deployment strategies (blue/green or canary)

Docs: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

#### Task 7: Blue/Green Deployment

1. Create a deployment `httpd-blue` that uses image `lisenet/httpd-pii-demo:0.2` and has these labels: `app=front-end` and `release=blue`. The deployment should run 2 replicas and expose port `80`.
2. Create a service `httpd-blue-green` that exposes the deployment `httpd-blue` on port `80`.
3. Create a deployment `httpd-green` that uses image `lisenet/httpd-pii-demo:0.3` and has these labels: `app=front-end` and `release=green`. The deployment should run 2 replicas and expose port `80`.
4. Update service `httpd-blue-green` configuration to route traffic to deployment `httpd-green`.

#### Solution 7

Imperative commands.

```bash
kubectl create deploy httpd-blue --image="lisenet/httpd-pii-demo:0.2" \
  --replicas=2 --port=80 \
  --dry-run=client -o yaml -n ckad > httpd-blue.yaml
```

Edit the file `httpd-blue.yaml` and add required labels:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: front-end
    release: blue
  name: httpd-blue
  namespace: ckad
spec:
  replicas: 2
  selector:
    matchLabels:
      app: front-end
      release: blue
  template:
    metadata:
      labels:
        app: front-end
        release: blue
    spec:
      containers:
      - image: lisenet/httpd-pii-demo:0.2
        name: httpd-pii-demo
        ports:
        - containerPort: 80
```

Create the blue deployment:

```bash
kubectl apply -f httpd-blue.yaml
```

Expose the deployment:

```bash
kubectl expose deployment httpd-blue --name=httpd-blue-green -n ckad
```

Create a new green deployment file by copying the existing blue one, and update the release label as well as container image:

```bash
cp httpd-blue.yaml httpd-green.yaml
sed -i 's/blue/green/g' httpd-green.yaml
sed -i 's/httpd-pii-demo:0.2/httpd-pii-demo:0.3/g' httpd-green.yaml
```

Create the green deployment:

```bash
kubectl apply -f httpd-green.yaml
```

Verify:

```bash
kubectl get deploy -n ckad
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
httpd-blue    2/2     2            2           9m22s
httpd-green   2/2     2            2           63s
```

Edit the service:

```bash
kubectl edit svc httpd-blue-green -n ckad
```

Update selector by chaging `release: blue` to `release: green`:

```yaml
  selector:
    app: front-end
    release: green
```

#### Task 8: Canary Deployment

1. Create a deployment `webapp-canary-blue` that uses image `kodekloud/webapp-color` and has a label of `app=webapp`. The deployment should run 3 replicas and expose port `8080`. Configure the deployment so that the underlying container has the environent variable `APP_COLOR` set to the value of blue.
2. Create a deployment `webapp-canary-green` that uses image `kodekloud/webapp-color` and has a label of `app=webapp`. The deployment should expose port `8080`. Configure the deployment so that the underlying container has the environent variable `APP_COLOR` set to the value of green.
3. Create a service `httpd-canary` that load balances request from both deployments on port `8080`.
4. Configure the deployment `webapp-canary-green` so that the service `httpd-canary` sends 75% of requests to deployment `httpd-canary-blue` and 25% to deployment `httpd-canary-green`.

#### Solution 8

Imperative commands.

```bash
kubectl create deploy webapp-canary-blue --image="kodekloud/webapp-color" \
  --replicas=3 --port=8080 \
  --dry-run=client -o yaml -n ckad > webapp-canary-blue.yaml
```

Edit the file `webapp-canary-blue.yaml` and add required labels, also add the evironment variable:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: webapp
  name: webapp-canary-blue
  namespace: ckad
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - image: kodekloud/webapp-color
        name: webapp-color
        ports:
        - containerPort: 8080
        env: 
        - name: APP_COLOR
          value: "blue"
```

Create the blue deployment:

```bash
kubectl apply -f webapp-canary-blue.yaml
```

Create a new green deployment file by copying the existing blue one and update the release label:

```bash
cp webapp-canary-blue.yaml webapp-canary-green.yaml
sed -i 's/blue/green/g' webapp-canary-green.yaml
```

Create the green deployment:

```bash
kubectl apply -f webapp-canary-green.yaml
```

Verify:

```bash
kubectl get deploy -n ckad
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
webapp-canary-blue    3/3     3            3           32m
webapp-canary-green   3/3     3            3           32m
```

```bash
kubectl get po --show-labels -n ckad
NAME                                   READY   STATUS    RESTARTS   AGE   LABELS
webapp-canary-blue-7f767d4c74-nh8zm    1/1     Running   0          32m   app=webapp,pod-template-hash=7f767d4c74
webapp-canary-blue-7f767d4c74-zkx6n    1/1     Running   0          32m   app=webapp,pod-template-hash=7f767d4c74
webapp-canary-blue-7f767d4c74-zm4ds    1/1     Running   0          32m   app=webapp,pod-template-hash=7f767d4c74
webapp-canary-green-5bb956f674-rvxnw   1/1     Running   0          32m   app=webapp,pod-template-hash=5bb956f674
webapp-canary-green-5bb956f674-rxhv7   1/1     Running   0          32m   app=webapp,pod-template-hash=5bb956f674
webapp-canary-green-5bb956f674-xmgtz   1/1     Running   0          32m   app=webapp,pod-template-hash=5bb956f674
```

Create a service template:

```bash
kubectl expose deployment webapp-canary-blue \
  --name=httpd-canary --port=8080 \
  --dry-run=client -o yaml -n ckad > httpd-canary.yaml
```

Edit the file `httpd-canary.yaml` and make sure that the service uses the right label `app: webapp`:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: webapp
  name: httpd-canary
  namespace: ckad
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: webapp
```

Create the service:

```bash
kubectl apply -f httpd-canary.yaml
```

Verify:

```bash
kubectl get svc -o wide -n ckad
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
httpd-canary   ClusterIP   10.100.237.144   <none>        8080/TCP  33m   app=webapp
```

Because we have the same amount of replicas for each deployment, the service should load balance requests fairly equally (50%/50%). In order to achieve 75%/25%, we are going to scale the green deployment replicas down from 3 to 1.

```bash
kubectl scale deploy webapp-canary-green --replicas=1 -n ckad
```

If we make a large number (e.g. 100) of requests to the service, we should see approximately 75% being routed to the blue deployment:

```bash
for i in $(seq 1 100); do curl -s http://10.100.237.144:8080 | grep webapp;done | grep -c blue
73
```

### Understand Deployments and how to perform rolling updates

Docs: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment

#### Task 9

1. Create a deployment object `nginx-deployment` consisting of 2 pods containing a single `nginx:1.21` container.
2. Increase the deployment size by adding 1 additional pod.
3. Update deployment container image to `nginx:1.21.0.0`.
4. Roll back a broken deployment to the previous version.

#### Solution 9

Imperative commands:

```bash
kubectl create deploy nginx-deployment --image=nginx:1.21 --replicas=2 -n ckad
kubectl scale deploy nginx-deployment --replicas=3 -n ckad
kubectl set image deployment/nginx-deployment nginx=nginx:1.21.1.1 -n ckad
kubectl rollout history deploy nginx-deployment -n ckad
kubectl rollout undo deploy nginx-deployment -n ckad
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
  namespace: ckad
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
  namespace: ckad
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
      - image: nginx:1.21.1.1
        name: nginx
```

### Use the Helm package manager to deploy existing packages

Docs: https://helm.sh/docs/

#### Task 10

1. Add Helm repository with a name of `prometheus-community` and URL **https://prometheus-community.github.io/helm-charts**.
2. Use Helm to deploy a Prometheus server. Install a new release `prometheus` of chart `prometheus-community/prometheus` and chart version `19.0.0`.
3. Customise Helm deployment and set Prometheus data retention to **1h**, disable Prometheus server **persistent volume**, also disable deployment of **Alertmanager**. Set these via Helm-values during install.
4. Resources should be deployed into `monitoring` namespace.
5. Upgrade Helm deployment in order to update Prometheus server version to `2.41.0` (application version). You can use any Helm chart version that provides application version `2.41.0`.
6. Delete Helm `prometheus` release.

#### Solution 10

Imperative commands.

Add Helm repository:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Work out what values are available for the given chart version:

```bash
helm show values prometheus-community/prometheus --version 19.0.0
```

Create a monitoring namespace and deploy Prometheus:

```bash
kubectl create ns monitoring

helm install prometheus \
  prometheus-community/prometheus \
  --namespace monitoring \
  --version 19.0.0 \
  --set retention=1h \
  --set server.persistentVolume.enabled=false \
  --set alertmanager.enabled=false
```

Verify:

```bash
helm ls -aA
NAME      	NAMESPACE 	REVISION	UPDATED                                	STATUS  	CHART            	APP VERSION
prometheus	monitoring	1       	2023-03-01 20:29:45.061483758 +0000 UTC	deployed	prometheus-19.0.0	v2.40.5 
```

Find out what application version comes with Helm chart `19.0.0`:

```bash
helm search repo prometheus-community/prometheus --version 19.0.0
NAME                           	CHART VERSION	APP VERSION	DESCRIPTION                                       
prometheus-community/prometheus	19.0.0       	v2.40.5    	Prometheus is a monitoring system and time seri...
```

List all releases and search for application version `2.41.0`:

```bash
helm search repo prometheus-community/prometheus -l | grep 2.41.0
prometheus-community/prometheus                   	19.7.2       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.7.1       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.6.1       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.6.0       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.5.0       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.4.0       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.3.3       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.3.2       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.3.1       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.3.0       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.2.2       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.2.1       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.2.0       	v2.41.0    	Prometheus is a monitoring system and time seri...
prometheus-community/prometheus                   	19.1.0       	v2.41.0    	Prometheus is a monitoring system and time seri...
```

We can use any chart version that provides application version `2.41.0`. We will go for chart `19.7.2`:

```bash
helm upgrade --install \
  prometheus \
  prometheus-community/prometheus \
  --namespace monitoring \
  --version 19.7.2 \
  --set retention=1h \
  --set server.persistentVolume.enabled=false \
  --set alertmanager.enabled=false
```

Verify:

```bash
helm ls -aA
NAME      	NAMESPACE 	REVISION	UPDATED                               	STATUS  	CHART            	APP VERSION
prometheus	monitoring	2       	2023-03-01 20:31:28.52568917 +0000 UTC	deployed	prometheus-19.7.2	v2.41.0 
```

Delete `prometheus` release:

```bash
helm -n monitoring uninstall prometheus
```

Note: if you somehowmanage to break your release, then by default, releases in pending-upgrade state won't be listed. However, you can show all to find and delete the broken one:

```bash
helm ls -a
```

## Application Observability and Maintenance

Unless stated otherwise, all Kubernetes resources should be created in the `ckad` namespace.

### Understand API deprecations

Docs: https://kubernetes.io/docs/reference/using-api/deprecation-guide/

#### Task 11

1. Use provided YAML file below to create a role. Fix any issues.

```yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: broken-role
  namespace: ckad
rules:
  - verbs:
      - "get"
      - "create"
      - "delete"
    apiGroups:
      - ''
    resources:
      - services/proxy
```

#### Solution 11

Imperative commands:

```bash
cat > broken-role.yaml <<EOF
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: broken-role
  namespace: ckad
rules:
  - verbs:
      - "get"
      - "create"
      - "delete"
    apiGroups:
      - ''
    resources:
      - services/proxy
EOF
```

Apply configuration from file:

```bash
kubectl apply -f broken-role.yaml

error: resource mapping not found for name: "broken-role" namespace: "ckad" from "./broken-role.yaml": no matches for kind "Role" in version "rbac.authorization.k8s.io/v1beta1"
ensure CRDs are installed first
```

The `rbac.authorization.k8s.io/v1beta1` API version of ClusterRole, ClusterRoleBinding, Role and RoleBinding is no longer served as of v1.22. Fix the API version:

```bash
sed -i 's#rbac.authorization.k8s.io/v1beta1#rbac.authorization.k8s.io/v1#g#' broken-role.yaml
```

Apply the config again:

```bash
kubectl apply -f broken-role.yaml
role.rbac.authorization.k8s.io/broken-role created
```

### Implement probes and health checks

Docs: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

#### Task 12

1. Create a pod `httpd-liveness-readiness` that uses `lisenet/httpd-healthcheck:1.0.0` image.
2. Configure a `readinessProbe` for an `httpGet` check using a path of `/index.html` and port `10001`.
3. Configure a `livenessProbe` for a TCP check on port `10001`.
4. Set `initialDelaySeconds` to 5. The probes should be performed every 10 seconds.

#### Solution 12

Imperative commands:

```bash
kubectl run httpd-liveness-readiness --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n ckad > httpd-liveness-readiness.yaml
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
  namespace: ckad
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-liveness-readiness
    readinessProbe:
      httpGet:
        path: /index.html
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
kubectl describe po/httpd-liveness-readiness -n ckad | egrep "Liveness|Readiness"
    Liveness:       tcp-socket :10001 delay=5s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:10001/index.html delay=5s timeout=1s period=10s #success=1 #failure=3
```

### Use provided tools to monitor Kubernetes applications

Docs: https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/

### Utilise container logs

Docs: https://kubernetes.io/docs/concepts/cluster-administration/logging/

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

### Debugging in Kubernetes

Docs:
* https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/
* https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/
* https://kubernetes.io/docs/tasks/debug/debug-cluster/

The first step in troubleshooting is triage. What is the problem? Is it your Pods, your Replication Controller or your Service?

Check the current state of the pod and recent events with the following command:

```bash
kubectl describe pods ${POD_NAME}
```

Next, verify that there are endpoints for the service. For every Service object, the apiserver makes an endpoints resource available. You can view this resource with:

```bash
kubectl get endpoints ${SERVICE_NAME}
```

## Application Environment, Configuration and Security

Unless stated otherwise, all Kubernetes resources should be created in the `ckad` namespace.

### Discover and use resources that extend Kubernetes (CRD)

Docs: https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/

#### Task 13

1. A `CustomResourceDefinition` YAML file is provided below. Use it to create the resource.

```yaml
# customresourcedefinition.yaml
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.stable.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: stable.example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      # Each version can be enabled/disabled by Served flag.
      served: true
      # One and only one version must be marked as the storage version.
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
  # either Namespaced or Cluster
  scope: Namespaced
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: crontabs
    # singular name to be used as an alias on the CLI and for display
    singular: crontab
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: CronTab
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ct
```

#### Solution 13

Imperative commands:

```bash
kubectl apply -f customresourcedefinition.yaml
```

Verify:

```bash
kubectl get customresourcedefinition
NAME                          CREATED AT
crontabs.stable.example.com   2023-03-02T19:12:35Z
```

### Understand authentication, authorisation and admission control

### Understanding and defining resource requirements, limits and quotas

Docs: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#example-1

#### Task 14

1. Create a pod `httpd-resource-limits` that uses `lisenet/httpd-healthcheck:1.0.0` image.
2. Set the pod memory request to `40Mi` and memory limit to `128Mi`.
3. Set the pod CPU request to `10m` and CPU limit to `50m`.

#### Solution 14

Imperative commands:

```bash
kubectl run httpd-resource-limits --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n ckad > httpd-resource-limits.yaml
```

Edit the file `httpd-resource-limits.yaml` and add `resources` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-resource-limits
  name: httpd-resource-limits
  namespace: ckad
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-resource-limits
    resources:
      requests:
        cpu: 10m
        memory: 40Mi
      limits:
        cpu: 50m
        memory: 128Mi
```

Deploy the pod:

```bash
kubectl apply -f httpd-resource-limits.yaml
```

Verify:

```bash
kubectl describe po/httpd-resource-limits -n ckad | egrep -A2 "Limits|Requests"
    Limits:
      cpu:     50m
      memory:  128Mi
    Requests:
      cpu:        10m
      memory:     40Mi
```

Docs: https://kubernetes.io/docs/concepts/policy/limit-range/

#### Task 15

1. Create a namespace `ckad-memlimit` with a container memory limit of 30Mi.
2. Create a pod `httpd-memlimit` that uses `lisenet/httpd-healthcheck:1.0.0` image in the `ckad-memlimit` namespace, and set the pod memory request to 100Mi.
3. Observe the error.

#### Solution 15

Imperative commands:

```bash
kubectl create ns ckad-memlimit
```

```bash
cat > ckad-memlimit.yaml <<EOF
---
apiVersion: v1
kind: LimitRange
metadata:
  name: ckad-memlimit
  namespace: ckad-memlimit
spec:
  limits:
  - max:
      memory: 30Mi
    type: Container
EOF
```

```bash
kubectl apply -f ckad-memlimit.yaml

kubectl run httpd-memlimit --image=lisenet/httpd-healthcheck:1.0.0 \
  --dry-run=client -o yaml -n ckad-memlimit > httpd-memlimit.yaml
```

Edit the file `httpd-memlimit.yaml` and add `resources` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: httpd-memlimit
  name: httpd-memlimit
  namespace: ckad-memlimit
spec:
  containers:
  - image: lisenet/httpd-healthcheck:1.0.0
    name: httpd-memlimit
    resources:
      requests:
        memory: 100Mi
```

Deploy the pod:

```bash
kubectl apply -f httpd-healthcheck-memlimit.yaml
The Pod "httpd-memlimit" is invalid: spec.containers[0].resources.requests: Invalid value: "100Mi": must be less than or equal to memory limit
```

### Understand ConfigMaps

Docs: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

#### Task 16

Configure application to use a `ConfigMap`.

1. Create a configmap `webapp-color` that has the following key=value pair:
    * `key` = color
    * `value` = blue
2. Create a pod `webapp-color` that uses `kodekloud/webapp-color` image.
3. Configure the pod so that the underlying container has the environent variable `APP_COLOR` set to the value of the configmap.
4. Check pod logs to ensure that the variable has been set correctly.

#### Solution 16

Imperative commands:

```bash
kubectl create cm webapp-color --from-literal=color=blue -n ckad
kubectl run webapp-color --image=kodekloud/webapp-color \
  --dry-run=client -o yaml -n ckad > webapp-color.yaml
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
  namespace: ckad
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
kubectl apply -f webapp-color.yaml
kubectl logs webapp-color -n ckad | grep "Color from environment variable"
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
  namespace: ckad
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webapp-color
  name: webapp-color
  namespace: ckad
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

#### Task 17

1. Create a configmap `grafana-ini` that containes a file named `grafana.ini` with the following content:
```ini
[server]
  protocol = http
  http_port = 3000
```
2. Create a pod `grafana` that uses `grafana/grafana:9.3.1` image.
3. Mount the configmap to the pod using `/etc/grafana/grafana.ini` as a `mountPath` and `grafana.ini` as a `subPath`.

#### Solution 17

Imperative commands:

```bash
cat > grafana.ini <<EOF
[server]
  protocol = http
  http_port = 3000
EOF
```

```bash
kubectl create configmap grafana-ini --from-file=grafana.ini -n ckad

kubectl run grafana --image=grafana/grafana:9.3.1 \
  --dry-run=client -o yaml -n ckad > grafana.yaml
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
  namespace: ckad
spec:
  containers:
  - image: grafana/grafana:9.3.1
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
kubectl apply -f grafana.yaml

kubectl exec grafana -n ckad -- cat /etc/grafana/grafana.ini
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
  namespace: ckad
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
  namespace: ckad
spec:
  containers:
  - image: grafana/grafana:9.3.1
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

### Create and consume Secrets

Docs: https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables

#### Task 18

Configure application to use a `Secret`.

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

#### Solution 18

Imperative commands:

```bash
kubectl create secret generic mysql-credentials \
  --from-literal=mysql_root_password="Mysql5.7RootPassword" \
  --from-literal=mysql_username=dbadmin \
  --from-literal=mysql_password="Mysql5.7UserPassword" \
  -n ckad

kubectl run mysql-pod-secret --image=mysql:5.7 \
  --dry-run=client -o yaml -n ckad > mysql-pod-secret.yaml
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
  namespace: ckad
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
kubectl exec mysql-pod-secret -n ckad -- env | grep ^MYSQL
MYSQL_MAJOR=5.7
MYSQL_VERSION=5.7.41-1.el7
MYSQL_SHELL_VERSION=8.0.32-1.el7
MYSQL_USER=dbadmin
MYSQL_PASSWORD=Mysql5.7UserPassword
MYSQL_ROOT_PASSWORD=Mysql5.7RootPassword
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-credentials
  namespace: ckad
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
  namespace: ckad
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

### Understand ServiceAccounts

Docs: https://kubernetes.io/docs/reference/access-authn-authz/rbac/

#### Task 19

1. Create a new service account `pod-sa`.
2. Create a cluster role `pod-clusterrole` that grants permissions `get,list,watch` to resources `pods,nodes` to API group `metrics.k8s.io`.
3. Grant the service account access to the cluster by creating a cluster role binding `pod-role-binding`.
4. Create a pod called `pod-use-sa` that uses the service account `pod-sa` and image `nginx:1.21`.

#### Solution 19

Imperative commands. Create a service account:

```bash
kubectl create sa pod-sa -n ckad
```

Create a cluser role:

```bash
kubectl create clusterrole pod-clusterrole \
  --verb=get,list,watch --resource=pods,nodes \
  --dry-run=client -o yaml | sed 's/- ""/- metrics.k8s.io/g' | kubectl apply -f -
```

Create a cluster role binding:

```bash
kubectl create clusterrolebinding pod-role-binding \
  --clusterrole=pod-clusterrole \
  --serviceaccount=ckad:pod-sa
```

Create a pod definition file:

```bash
kubeclt run pod-use-sa --image=nginx:1.21 \
  --dry-run=client -o yaml -n ckad > pod-use-sa.yaml
```

Edit the file `pod-use-sa.yaml` and add `serviceAccount` section:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod-use-sa
  name: pod-use-sa
  namespace: ckad
spec:
  serviceAccount: pod-sa
  serviceAccountName: pod-sa
  containers:
  - image: nginx:1.21
    name: pod-use-sa
```

Deploy the pod:

```bash
kubectl apply -f pod-use-sa.yaml
```

Verify:

```bash
kubectl describe po pod-use-sa -n ckad | grep Service
Service Account:  pod-sa
```

Declarative YAML:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-sa
  namespace: ckad
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-clusterrole
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pod-clusterrole
subjects:
- kind: ServiceAccount
  name: pod-sa
  namespace: ckad
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod-use-sa
  name: pod-use-sa
  namespace: ckad
spec:
  serviceAccount: pod-sa
  serviceAccountName: pod-sa
  containers:
  - image: nginx:1.21
    name: pod-use-sa
```

### Understand SecurityContexts

Docs: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

#### Task 20

1. Create a new pod called `unprivileged` that uses image `busybox:1.35` and runs command `sleep 1800`.
2. Set `allowPrivilegeEscalation: false` and `privileged: false` for the security context on container level.
3. The pod should run as UID `1111`. The container should run as UID `2222`.
4. Add `SYS_TIME` capabilities to the container.

#### Solution 20

Imperative commands.

```bash
kubectl run unprivileged --image=busybox:1.35 \
  --dry-run=client -o yaml -n ckad -- sleep 1800 > unprivileged.yaml
```

Edit the file `unprivileged.yaml` and add `securityContext` section.

Note that Linux capabilities can be added only at container level security-context, not at the pod level.


```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: unprivileged
  name: unprivileged
  namespace: ckad
spec:
  securityContext:
    runAsUser: 1111
  containers:
  - args:
    - sleep
    - "1800"
    image: busybox:1.35
    name: unprivileged
    securityContext:
      allowPrivilegeEscalation: false
      runAsUser: 2222
      capabilities:
        add: ["SYS_TIME"]
```

Deploy the pod:

```bash
kubectl apply -f unprivileged.yaml
```

## Services and Networking

Unless stated otherwise, all Kubernetes resources should be created in the `ckad` namespace.

### Demonstrate basic understanding of NetworkPolicies

Docs: https://kubernetes.io/docs/concepts/services-networking/network-policies/

#### Task 21

1. Create a pod `httpd-netpol-blue` that uses image `lisenet/httpd-pii-demo:0.2` and has a label of `app=blue`.
2. Create a pod `httpd-netpol-green` that uses image `lisenet/httpd-pii-demo:0.3` and has a label of `app=green`.
3. Create a pod `curl-netpol` that uses image `curlimages/curl:7.87.0` and has a label of `app=admin`. The pod should run the following command `sleep 1800`.
4. Create a `NetworkPolicy` called `netpol-blue-green`.
5. The policy should allow the `busybox` pod only to:
    * connect to `httpd-netpol-blue` pods on port `80`.
6. Use the `app` label of pods in your policy.

After implementation, connections from `busybox` pod to `httpd-netpol-green` pod on port `80` should no longer work.

#### Solution 21

Imperative commands. Create pods:

```bash
kubectl run httpd-netpol-blue --image="lisenet/httpd-pii-demo:0.2" --labels=app=blue -n ckad
kubectl run httpd-netpol-green --image="lisenet/httpd-pii-demo:0.3" --labels=app=green -n ckad
kubectl run curl-netpol --image="curlimages/curl:7.87.0" --labels=app=admin -n ckad -- sleep 1800
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
Date: Tue, 21 Feb 2023 01:05:37 GMT
Server: Apache/2.4.48 (Debian)
X-Powered-By: PHP/7.3.30
Content-Type: text/html; charset=UTF-8

kubectl -n cka exec curl-netpol -- curl -sI http://192.168.137.40
HTTP/1.1 200 OK
Date: Tue, 21 Feb 2023 01:05:37 GMT
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
  namespace: ckad
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

kubectl get networkpolicy -n ckad
NAME                POD-SELECTOR   AGE
netpol-blue-green   app=admin      29s
```

Test web access again:

```bash
kubectl -n cka exec curl-netpol -- curl -sI --max-time 5 http://192.168.137.36
HTTP/1.1 200 OK
Date: Tue, 21 Feb 2023 01:05:37 GMT
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
  namespace: ckad
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
  namespace: ckad
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
  namespace: ckad
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
  namespace: ckad
spec:
  containers:
  - args:
    - "sleep"
    - "1800"
    image: curlimages/curl:7.87.0
    name: curl-netpol
```

### Provide and troubleshoot access to applications via services

#### Task 22

1. A deployment YAML file for a `troublesome-app` application is provided below. Use it to deploy a service that exposes a pod on `NodePort: 30080`.
2. Do not change the pod definition. Assume that the pod definition is correct.
3. Troubleshoot access problem and fix it so that the application would be available via a `NodePort` service.
4. Test access with `curl -s http://127.0.0.1:30080`.

```yaml
# troublesome-app.yaml
---
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cluster-autoscaler.kubernetes.io/safe-to-evict: "true"
  labels:
    app: web
    tier: frontend
  name: troublesome-app
  namespace: ckad
spec:
  containers:
  - name: troublesome-pod
    image: kodekloud/webapp-color
    imagePullPolicy: IfNotPresent
    env:
    - name: APP_COLOR
      value: red
    ports:
    - containerPort: 8080
    resources:
      limits:
        cpu: 50m
  dnsPolicy: ClusterFirst
  restartPolicy: Always
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: troublesome-app-ingress-netpol
  namespace: ckad
spec:
  podSelector:
    matchLabels:
      tier: frontend
  ingress:
  - {}
  policyTypes:
  - Ingress
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: wepapp-color
  name: troublesome-app
  namespace: ckad
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30080
  type: NodePort
  selector:
    app: wepapp-color
```

### Use Ingress rules to expose applications

Docs:

* https://kubernetes.io/docs/concepts/services-networking/ingress/
* https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/

Note: you must have an Ingress controller to satisfy an Ingress. Only creating an Ingress resource has no effect.

#### Task 23

1. Create a deployment object `httpd-pii-demo-blue` containing a single `lisenet/httpd-pii-demo:0.2` container and expose its port `80` through a type `LoadBalancer` service.
2. Create a deployment object `httpd-pii-demo-green` containing a single `lisenet/httpd-pii-demo:0.3` container and expose its port `80` through a type `LoadBalancer` service.
3. Deploy `ingress-nginx` controller.
4. Create the ingress resource `ingress-blue-green` to make the applications available at `/blue` and `/green` on the `Ingress` service.

#### Solution 23

Imperative commands. Create and expose deployments:

```bash
kubectl create deploy httpd-pii-demo-blue --image="lisenet/httpd-pii-demo:0.2" -n ckad
kubectl expose deploy/httpd-pii-demo-blue --port=80 --target-port=80 --type=LoadBalancer -n ckad

kubectl create deploy httpd-pii-demo-green --image="lisenet/httpd-pii-demo:0.3" -n ckad
kubectl expose deploy/httpd-pii-demo-green --port=80 --target-port=80 --type=LoadBalancer -n ckad
```

Deploy an ingress resource:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/cloud/deploy.yaml
```

Verify:

```bash
kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.110.55.43     <pending>     80:30740/TCP,443:32596/TCP   49s
ingress-nginx-controller-admission   ClusterIP      10.106.169.189   <none>        443/TCP                      49s
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
  namespace: ckad
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
```

```bash
kubectl describe ingress/ingress-blue-green -n ckad
Name:             ingress-blue-green
Labels:           <none>
Namespace:        ckad
Address:          
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /blue    httpd-pii-demo-blue:80 (10.244.1.50:80)
              /green   httpd-pii-demo-green:80 (10.244.1.51:80)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  Sync    13s   nginx-ingress-controller  Scheduled for sync
```

