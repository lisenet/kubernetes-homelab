data "kubectl_path_documents" "monitoring_ns_with_istio" {
  pattern          = "../monitoring-ns-with-istio/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "monitoring_ns_with_istio" {
  count     = length(data.kubectl_path_documents.monitoring_ns_with_istio.documents)
  yaml_body = element(data.kubectl_path_documents.monitoring_ns_with_istio.documents, count.index)

  depends_on = [
    kubectl_manifest.monitoring_ns,
    kubectl_manifest.istio
  ]
}
