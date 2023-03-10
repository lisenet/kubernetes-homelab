data "kubectl_path_documents" "prometheus" {
  pattern          = "../kubernetes/prometheus/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "prometheus" {
  count     = length(data.kubectl_path_documents.prometheus.documents)
  yaml_body = element(data.kubectl_path_documents.prometheus.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio,
    kubectl_manifest.monitoring_ns
  ]
}
