# Homelab Sofware Versions

## Requirements

Kubernetes development continues to grow at a rapid pace, and keeping up to date can be a challenge. Therefore it's important to know which software versions can work together without breaking things.

* Rocky Linux 9.4
* Kubernetes 1.30.4
* Calico CNI 3.28.1
* containerd 1.6.20
* kubernetes-cni 1.4.0
* Istio 1.23

Other services (in alphabetical order):

* Alertmanager 0.23.0
* Argo CD 2.3.2
* CoreDNS 1.11.1
* Democratic CSI 0.13.7
* Grafana 9.5.2
* Homeassistant 2023.7
* InfluxDB 2.1.1
* Kubecost 1.105.1
* Kubernetes Dashboard 2.7.0
* Loki 2.9.0
* MetalLB 0.12.1
* Metrics Server 0.6.1
* Mikrotik Exporter 1.0.11
* OpenVPN 2.6
* Pihole Exporter 0.3.0
* Prometheus 2.34.0
* Promtail 2.6.1
* Speedtest-to-InfluxDB 1.0.1
* Velero 1.8.1
* x509-certificate-exporter 3.6.0

[Calico 3.28](https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements#kubernetes-requirements) has been tested against the following Kubernetes versions: 1.27, 1.28, 1.29, 1.30.

[Istio 1.23](https://istio.io/latest/docs/releases/supported-releases/#support-status-of-istio-releases) has been tested with these Kubernetes releases: 1.27, 1.28, 1.29, 1.30.

Kubernetes 1.21 updated the latest validated version of Docker to 20.10. As of [Kubernetes 1.24](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.24.md#dockershim-removed-from-kubelet), Docker runtime support using dockshim in the kubelet has been completely removed.

SELinux set to enforcing mode on all Rocky Linux 9 servers.
