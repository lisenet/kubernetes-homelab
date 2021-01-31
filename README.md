# kubernetes-homelab

A repository to keep resources and configuration files used with my Kubernetes homelab.

## Resources

[`Install and Configure a Multi-Master HA Kubernetes Cluster with kubeadm, HAProxy and Keepalived on CentOS 7`](https://www.lisenet.com/2021/install-and-configure-a-multi-master-ha-kubernetes-cluster-with-kubeadm-haproxy-and-keepalived-on-centos-7/)

[`Install Kubernetes Dashboard`](https://www.lisenet.com/2021/install-kubernetes-dashboard/)

[`Install and Configure Prometheus Monitoring on Kubernetes`](https://www.lisenet.com/2021/install-and-configure-prometheus-monitoring-on-kubernetes/)

[`Install and Configure Grafana on Kubernetes`](https://www.lisenet.com/2021/install-and-configure-grafana-on-kubernetes/)

[`Monitor Etcd Cluster with Grafana and Prometheus`](https://www.lisenet.com/2021/monitor-etcd-cluster-with-grafana-and-prometheus/)


## Create a Homelab ROOT CA
```
vim /etc/pki/tls/certs/make-dummy-cert
openssl req -newkey rsa:2048 -keyout homelab-ca.key -nodes -x509 -days 3650 -out homelab-ca.crt
```

## Create a Kubernetes Wildcard Cert Signed by the ROOT CA
```
DOMAIN=wildcard.apps.hl.test
openssl genrsa -out "${DOMAIN}".key 2048 && chmod 0600 "${DOMAIN}".key
openssl req -new -sha256 -key "${DOMAIN}".key -out "${DOMAIN}".csr
openssl x509 -req -in "${DOMAIN}".csr -CA homelab-ca.crt -CAkey homelab-ca.key -CAcreateserial -out "${DOMAIN}".crt -days 1825 -sha256
```

## Homelab Network Diagram

![Homelab Network Diagram](./docs/kubernetes-homelab-diagram.png)
