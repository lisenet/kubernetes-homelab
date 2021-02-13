# kubernetes-homelab

A repository to keep resources and configuration files used with my Kubernetes homelab.

## TL;DR

Create a monitoring namespace:
```
$ kubectl create ns monitoring
```

Deploy `kube-state-metrics`:
```
$ kubectl apply -f ./kube-state-metrics
```

Deploy `prometheus`:
```
$ kubectl apply -f ./prometheus
```

Deploy `grafana`:
```
$ kubectl apply -f ./grafana
```

Deploy `alertmanager`:
```
$ kubectl apply -f ./alertmanager
```
Alertmanager uses the Incoming Webhooks feature of Slack, therefore you need to set it up if you want to receive Slack alerts.


Deploy `mikrotik-exporter`:
```
$ kubectl apply -f ./mikrotik-exporter
```

## Resources

[`Install and Configure a Multi-Master HA Kubernetes Cluster with kubeadm, HAProxy and Keepalived on CentOS 7`](https://www.lisenet.com/2021/install-and-configure-a-multi-master-ha-kubernetes-cluster-with-kubeadm-haproxy-and-keepalived-on-centos-7/)

[`Install Kubernetes Dashboard`](https://www.lisenet.com/2021/install-kubernetes-dashboard/)

[`Install Kube State Metrics on Kubernetes`](https://www.lisenet.com/2021/install-kube-state-metrics-on-kubernetes/)

[`Install and Configure Prometheus Monitoring on Kubernetes`](https://www.lisenet.com/2021/install-and-configure-prometheus-monitoring-on-kubernetes/)

[`Install and Configure Grafana on Kubernetes`](https://www.lisenet.com/2021/install-and-configure-grafana-on-kubernetes/)

[`Monitor Etcd Cluster with Grafana and Prometheus`](https://www.lisenet.com/2021/monitor-etcd-cluster-with-grafana-and-prometheus/)

[`Monitor Bind DNS Server with Grafana and Prometheus (bind_exporter)`](https://www.lisenet.com/2021/monitor-bind-dns-server-with-grafana-and-prometheus-bind_exporter/)

[`Monitor HAProxy with Grafana and Prometheus (haproxy_exporter)`](https://www.lisenet.com/2021/monitor-haproxy-with-grafana-and-prometheus-haproxy_exporter/)

[`Monitor Linux Servers with Grafana and Prometheus (node_exporter)`](https://www.lisenet.com/2021/monitor-linux-servers-with-grafana-and-prometheus-node_exporter/)

## Create a Homelab ROOT CA
Create your own Certificate Authority (CA) for homelab environment. Run the following a CentOS 7 server:

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
