# Homelab Sofware Versions

## Requirements

Kubernetes development continues to grow at a rapid pace, and keeping up to date can be a challenge. Therefore it’s important to know which software versions can work together without breaking things.

* CentOS 7
* Kubernetes 1.19.7
* Calico CNI 3.17
* docker-ce 19.03
* kubernetes-cni 0.8.7
* Istio 1.9

According to Calico project documentation, Calico 3.17 has been tested against the following Kubernetes versions: 1.17, 1.18, 1.19. Kubernetes 1.20 is not on the list yet, therefore we use Kubernetes 1.19.

Istio 1.9 has been tested with these Kubernetes releases: 1.17, 1.18, 1.19, 1.20.

Unfortunatelly I could not find supported Docker versions in the Relase Notes for Kubernetes 1.19, so I decided to use docker-ce 19.03.

SELinux set to enforcing mode and firewalld is enabled on all servers.
