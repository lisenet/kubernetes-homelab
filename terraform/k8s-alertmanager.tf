data "kubectl_path_documents" "alertmanager" {
  pattern          = "../alertmanager/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "alertmanager" {
  count     = length(data.kubectl_path_documents.alertmanager.documents)
  yaml_body = element(data.kubectl_path_documents.alertmanager.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio,
    kubectl_manifest.monitoring_ns
  ]
}
