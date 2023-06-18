data "kubectl_path_documents" "grafana" {
  pattern          = "../kubernetes/grafana/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "grafana" {
  count     = length(data.kubectl_path_documents.grafana.documents)
  yaml_body = element(data.kubectl_path_documents.grafana.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio,
    kubectl_manifest.monitoring_ns
  ]
}
