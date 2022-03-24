# Argo CD

See https://argoproj.github.io/cd/

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

## Deploy Argo CD

```
kubectl create namespace argocd
kubectl apply -n argocd -f ./argocd-install.yaml
```

Optional: set up TLS.

```
kubectl -n argocd create secret tls argocd-server-tls \
  --cert=../hl-ca/wildcard.hl.test.crt \
  --key=../hl-ca/wildcard.hl.test.key

kubectl -n argocd create secret tls argocd-repo-server-tls \
  --cert=../hl-ca/wildcard.hl.test.crt \
  --key=../hl-ca/wildcard.hl.test.key
```

Log in:

```
argocd login argocd.hl.test
```

## Deploy PII Demo App

Use Argo CD to deploy the PII Demo application.

```
argocd proj create pii-demo \
  --allow-cluster-resource "Namespace" \
  --dest "https://kubernetes.default.svc,pii-demo" \
  --src "https://github.com/lisenet/kubernetes-homelab.git"

argocd app create pii-demo \
  --project pii-demo \
  --repo https://github.com/lisenet/kubernetes-homelab.git \
  --path pii-demo-blue-green \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace pii-demo

argocd app get pii-demo
argocd app sync pii-demo
```
