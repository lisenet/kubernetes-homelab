data "kubectl_path_documents" "speedtest-influxdb" {
  pattern = "../speedtest-influxdb/*.y*ml"
}

resource "kubectl_manifest" "speedtest-influxdb" {
  count     = length(data.kubectl_path_documents.speedtest-influxdb.documents)
  yaml_body = element(data.kubectl_path_documents.speedtest-influxdb.documents, count.index)

  depends_on = [
    kubectl_manifest.calico
  ]
}
