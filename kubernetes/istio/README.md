[[Back to Index Page](../README.md)]

# Istio

See https://istio.io/latest/docs/concepts/what-is-istio/

## What's so great about Istio?

Mutual TLS (mTLS). You can enforce mTLS such that only TLS traffic is accepted by all services in all Istio-injected namespaces.

## Istio Generate a YAML Manifest

Note that `istio-operator.yml` is an Istio operator YAML file. This is not a Kubernetes YAML file. If you attemt to apply it using `kubectl` it will fail, because it does not recognise it as a Kubernetes file.

If you want to generate a YAML file that does exactly the same thing that you would be doing with `istioctl install` using the operator file, you need to run it through a processor:

```bash
istioctl manifest generate -f ./istio-operator.yml --set values.global.jwtPolicy=first-party-jwt > ./istio-kubernetes.yml
```

The output is a Kubernetes YAML file that can be used with `kubectl apply`. Note that you can skip the `--set values` parameter if your cluster supports third party tokens. While AWS cloud provider, and possibly others, supports this feature (I use it myself), many local development tools and custom installations may not prior to Kubernetes 1.20.

Use the following if your cluster supports third party tokens:

```bash
istioctl manifest generate -f ./istio-operator.yml --set values.global.jwtPolicy=third-party-jwt > ./istio-kubernetes.yml
```

## Install Istio

The Istio namespace must be created manually.

```bash
kubectl create ns istio-system
```

The `kubectl apply` command may show transient errors due to resources not being available in the cluster in the correct order. If that happens, simply run the command again.

```bash
kubectl apply -f ./istio-kubernetes.yml
```

Install httpd-healthcheck:

```bash
kubectl apply -f ../httpd-healthcheck/
```

Expected output:

```bash
kubectl -n istio-system get svc
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                         AGE
istio-ingressgateway   LoadBalancer   10.99.133.23     10.11.1.52    10001:32104/TCP,443:30175/TCP,15021:30860/TCP   73m
istiod                 ClusterIP      10.103.218.247   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP           73m
kiali                  ClusterIP      10.109.213.166   <none>        20001/TCP,9090/TCP                              36m
```

Note that I use MetalLB as a network load balancer implementation for my bare metal homelab cluster.

## References

https://istio.io/latest/docs/setup/install/istioctl/

https://istio.io/latest/docs/setup/additional-setup/config-profiles/

https://istio.io/latest/docs/ops/best-practices/security/#configure-third-party-service-account-tokens

https://github.com/istio/istio/releases