resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

# https://istio.io/latest/docs/setup/install/helm/
resource "helm_release" "istio-base" {
  name       = "istio-base"
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  version    = "1.26.2"
}

resource "helm_release" "istiod" {
  name       = "istiod"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = helm_release.istio-base.namespace
  version    = "1.26.2"

  values = [
    file("../../kubernetes/istio/helm-istiod-values.yaml")
  ]
}

resource "kubernetes_namespace" "istio-ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "istio-ingress" {
  name       = "istio-ingress"
  chart      = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio-ingress.metadata[0].name
  version    = "1.26.2"
  values = [
    file("../../kubernetes/istio/helm-ingressgateway-values.yaml")
  ]

  depends_on = [
    helm_release.istiod
  ]
}
