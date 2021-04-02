# Istio

See https://istio.io/latest/docs/concepts/what-is-istio/

## What's so great about Istio?

Mutual TLS (mTLS). You can enforce mTLS such that only TLS traffic is accepted by all services in all Istio-injected namespaces.

## Istio Generate a YAML Manifest

Note that `istio-operator.yml` is an Istio operator YAML file. This is not a Kubernetes YAML file. If you attemt to apply it using `kubectl` it will fail, because it does not recognise it as a Kubernetes file.

If you want to generate a YAML file that does exactly the same thing that you would be doing with `istioctl install` using the operator file, you need to run it through a processor:

```
istioctl manifest generate -f ./istio-operator.yml --set values.global.jwtPolicy=first-party-jwt > ./istio-kubernetes.yml
```

The output is a Kubernetes YAML file that can be used with `kubectl apply`. Note that you can skip the `--set values` parameter if your cluster supports third party tokens. While AWS cloud provider, and possibly others, supports this feature (I use it myself), many local development tools and custom installations may not prior to Kubernetes 1.20.

## Install Istio

The Istio namespace must be created manually.

```
kubectl create ns istio-system
```

The `kubectl apply` command may show transient errors due to resources not being available in the cluster in the correct order. If that happens, simply run the command again.
```
kubectl apply -f ./istio-kubernetes.yml
```

Install httpd-healthcheck:
```
kubectl apply -f ../httpd-healthcheck/
```

## References

https://istio.io/latest/docs/setup/install/istioctl/

https://istio.io/latest/docs/setup/additional-setup/config-profiles/

https://istio.io/latest/docs/ops/best-practices/security/#configure-third-party-service-account-tokens

https://github.com/istio/istio/releases
