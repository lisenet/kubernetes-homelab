resource "helm_release" "metallb" {
  name             = "metallb"
  chart            = "metallb"
  repository       = "https://metallb.github.io/metallb"
  namespace        = "metallb-system"
  create_namespace = true
  version          = "0.15.2"

  values = [
    file("../../kubernetes/metallb/helm-values.yaml")
  ]
}

data "kubectl_path_documents" "metallb" {
  pattern          = "../../kubernetes/metallb/*.yml"
  disable_template = true
}

# MetalLB remains idle until configured
resource "kubectl_manifest" "metallb" {
  for_each  = data.kubectl_path_documents.metallb.manifests
  yaml_body = each.value

  depends_on = [
    helm_release.metallb
  ]
}
