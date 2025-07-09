# helm pull projectcalico/tigera-operator --untar --untardir tigera-operator
resource "helm_release" "calico" {
  name             = "calico"
  chart            = "tigera-operator"
  repository       = "https://docs.tigera.io/calico/charts"
  namespace        = "tigera-operator"
  create_namespace = true
  version          = "v3.30.2"

  values = [
    file("../../kubernetes/calico/helm-values.yaml")
  ]
}
