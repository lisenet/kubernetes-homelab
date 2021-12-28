data "kubectl_path_documents" "pii_demo" {
  pattern = "../pii-demo-blue-green/*.y*ml"
}

resource "kubectl_manifest" "pii_demo" {
  count     = length(data.kubectl_path_documents.pii_demo.documents)
  yaml_body = element(data.kubectl_path_documents.pii_demo.documents, count.index)

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio
  ]
}
