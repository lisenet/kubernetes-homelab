data "kubectl_file_documents" "monitoring_ns" {
  content          = file("../kubernetes/monitoring-ns-istio-injection-enabled.yml")
}

resource "kubectl_manifest" "monitoring_ns" {
  count     = length(data.kubectl_file_documents.monitoring_ns.documents)
  yaml_body = element(data.kubectl_file_documents.monitoring_ns.documents, count.index)
}
