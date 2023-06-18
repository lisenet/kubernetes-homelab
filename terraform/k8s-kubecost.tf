resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  namespace  = "kubecost"
  version    = "1.87.3"

  values = [
    "${file("../kubernetes/charts/kubecost/values.yaml")}"
  ]

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.prometheus
  ]
}