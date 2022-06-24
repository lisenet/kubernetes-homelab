data "kubectl_path_documents" "istio_addons_kiali" {
  pattern          = "../istio-addons/kiali/*.y*ml"
  disable_template = true
}
data "kubectl_path_documents" "istio_addons_prometheus" {
  pattern          = "../istio-addons/prometheus/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "istio_addons_kiali" {
  count     = length(data.kubectl_path_documents.istio_addons_kiali.documents)
  yaml_body = element(data.kubectl_path_documents.istio_addons_kiali.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio
  ]
}

resource "kubectl_manifest" "istio_addons_prometheus" {
  count     = length(data.kubectl_path_documents.istio_addons_prometheus.documents)
  yaml_body = element(data.kubectl_path_documents.istio_addons_prometheus.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio
  ]
}
