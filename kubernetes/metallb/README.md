[[Back to Index Page](../README.md)]

# MetalLB

See https://metallb.org/

## What's so great about MetalLB?

Kubernetes does not offer an implementation of network load-balancers (Services of type LoadBalancer) for bare metal clusters.

MetalLB aims to redress this imbalance by offering a network LB implementation that integrates with standard network equipment, so that external services on bare metal clusters "just work".

## Install MetalLB

Enable strict ARP mode.

```bash
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```

Update the config map [`metallb-config-map.yml`](./metallb-config-map.yml) and specify the IP address range. Deploy MetalLB network load-balancer:

```bash
kubectl apply -f ./metallb
```
