# Homelab Sofware Versions

## Requirements

Kubernetes development continues to grow at a rapid pace, and keeping up to date can be a challenge. Therefore it’s important to know which software versions can work together without breaking things.

* Rocky Linux 8 (not officially supported, use CentOS 7 instead)
* Kubernetes 1.23.5
* Calico CNI 3.22
* docker-ce 20.10.11
* kubernetes-cni 0.8.7
* Istio 1.13

Other services (in alphabetical order):

* Alertmanager 0.23
* CoreDNS 1.8.6
* Democratic CSI 0.11.1
* ElasticSearch/Kibana 7.17.1
* Grafana 8.4.4
* Kube State Metrics 1.9.7
* Kubecost 1.91.2
* Kubernetes Dashboard 2.5.1
* MetalLB 0.12.1
* Metrics Server 0.6.1
* Mikrotik Exporter 1.0.11
* OpenVPN 2.5
* Pihole Exporter 0.3.0
* Prometheus 2.34
* x509-certificate-exporter 2.12.0

Calico 3.22 has been tested against the following Kubernetes versions: 1.21, 1.22, 1.23.

Istio 1.13 has been tested with these Kubernetes releases: 1.20, 1.21, 1.22, 1.23.

Kubernetes 1.21 updated the latest validated version of Docker to 20.10.

SELinux set to enforcing mode and firewalld is enabled on all CentOS 7 servers.
