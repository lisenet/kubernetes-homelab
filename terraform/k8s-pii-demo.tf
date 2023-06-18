data "kubectl_path_documents" "pii_demo" {
  pattern          = "../kubernetes/pii-demo-blue-green/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "pii_demo" {
  count     = length(data.kubectl_path_documents.pii_demo.documents)
  yaml_body = element(data.kubectl_path_documents.pii_demo.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio
  ]
}
