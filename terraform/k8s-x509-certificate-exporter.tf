resource "helm_release" "x509-certificate-exporter" {
  name       = "x509-certificate-exporter"
  chart      = "../charts/x509-certificate-exporter/"
  namespace  = "monitoring"

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio,
    kubectl_manifest.monitoring_ns
  ]
}
