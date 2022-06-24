data "kubectl_file_documents" "istio" {
  content          = file("../istio/istio-kubernetes.yml")
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubectl_manifest" "istio" {
  count     = length(data.kubectl_file_documents.istio.documents)
  yaml_body = element(data.kubectl_file_documents.istio.documents, count.index)

  depends_on = [
    kubectl_manifest.calico
  ]
}
