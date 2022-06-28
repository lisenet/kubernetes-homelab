data "kubectl_file_documents" "monitoring_ns" {
  content          = file("../monitoring-ns-istio-injection-enabled.yml")
  disable_template = true
}

resource "kubectl_manifest" "monitoring_ns" {
  count     = length(data.kubectl_file_documents.monitoring_ns.documents)
  yaml_body = element(data.kubectl_file_documents.monitoring_ns.documents, count.index)
}
