data "kubectl_path_documents" "kube_state_metrics" {
  pattern          = "../kubernetes/kube_state_metrics/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "kube_state_metrics" {
  count     = length(data.kubectl_path_documents.kube_state_metrics.documents)
  yaml_body = element(data.kubectl_path_documents.kube_state_metrics.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio,
    kubectl_manifest.monitoring_ns
  ]
}
