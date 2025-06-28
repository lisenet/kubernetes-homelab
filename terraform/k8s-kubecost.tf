resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  namespace  = "kubecost"
  version    = "2.8.0"

  values = [
    "${file("../kubernetes/helm/kubecost/values.yaml")}"
  ]

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.prometheus
  ]
}
