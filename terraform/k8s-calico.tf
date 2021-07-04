data "kubectl_path_documents" "calico" {
  pattern = "../calico/*.y*ml"
}

resource "kubectl_manifest" "calico" {
  count     = length(data.kubectl_path_documents.calico.documents)
  yaml_body = element(data.kubectl_path_documents.calico.documents, count.index)
}
