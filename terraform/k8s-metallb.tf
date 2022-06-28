data "kubectl_path_documents" "metallb" {
  pattern          = "../metallb/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "metallb" {
  count     = length(data.kubectl_path_documents.metallb.documents)
  yaml_body = element(data.kubectl_path_documents.metallb.documents, count.index)

  depends_on = [
    kubectl_manifest.calico
  ]
}
