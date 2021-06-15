# Homelab Sofware Versions

## Requirements

Kubernetes development continues to grow at a rapid pace, and keeping up to date can be a challenge. Therefore it’s important to know which software versions can work together without breaking things.

* CentOS 7
* Kubernetes 1.21.1
* Calico CNI 3.19
* docker-ce 20.10.7
* kubernetes-cni 0.8.7
* Istio 1.9

According to Calico project documentation, Calico 3.19 has been tested against the following Kubernetes versions: 1.19, 1.20, 1.21.

Istio 1.9 has been tested with these Kubernetes releases: 1.17, 1.18, 1.19, 1.20.

Kubernetes 1.21 updated the latest validated version of Docker to 20.10.

SELinux set to enforcing mode and firewalld is enabled on all servers.
