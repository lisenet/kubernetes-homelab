# Homelab Sofware Versions

## Requirements

Kubernetes development continues to grow at a rapid pace, and keeping up to date can be a challenge. Therefore it’s important to know which software versions can work together without breaking things.

* Rocky Linux 8 (not officially supported, use CentOS 7 instead)
* Kubernetes 1.21.1
* Calico CNI 3.20
* docker-ce 20.10.7
* kubernetes-cni 0.8.7
* Istio 1.10

Calico 3.20 has been tested against the following Kubernetes versions: 1.19, 1.20, 1.21.

Istio 1.10 has been tested with these Kubernetes releases: 1.18, 1.19, 1.20, 1.21.

Kubernetes 1.21 updated the latest validated version of Docker to 20.10.

SELinux set to enforcing mode and firewalld is enabled on all CentOS 7 servers.
