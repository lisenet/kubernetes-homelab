data "kubectl_path_documents" "speedtest-influxdb" {
  pattern          = "../kubernetes/speedtest-influxdb/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "speedtest-influxdb" {
  count     = length(data.kubectl_path_documents.speedtest-influxdb.documents)
  yaml_body = element(data.kubectl_path_documents.speedtest-influxdb.documents, count.index)

  depends_on = [
    kubectl_manifest.calico
  ]
}
