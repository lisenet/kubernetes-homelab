data "kubectl_path_documents" "dashboard" {
  pattern          = "../kubernetes/dashboard/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "dashboard" {
  count     = length(data.kubectl_path_documents.dashboard.documents)
  yaml_body = element(data.kubectl_path_documents.dashboard.documents, count.index)
}
