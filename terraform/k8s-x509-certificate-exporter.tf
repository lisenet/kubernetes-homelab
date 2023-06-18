resource "helm_release" "x509-certificate-exporter" {
  name       = "x509-certificate-exporter"
  repository = "https://helm.enix.io"
  chart      = "x509-certificate-exporter"
  namespace  = "monitoring"

  values = [
    "${file("../kubernetes/helm/x509-certificate-exporter/values.yml")}"
  ]

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.istio,
    kubectl_manifest.monitoring_ns
  ]
}
