data "kubectl_path_documents" "dashboard" {
  pattern = "../dashboard/*.y*ml"
}

resource "kubectl_manifest" "dashboard" {
  count     = length(data.kubectl_path_documents.dashboard.documents)
  yaml_body = element(data.kubectl_path_documents.dashboard.documents, count.index)
}
