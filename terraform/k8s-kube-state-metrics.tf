data "kubectl_path_documents" "kube_state_metrics" {
  pattern = "../kube_state_metrics/*.y*ml"
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
