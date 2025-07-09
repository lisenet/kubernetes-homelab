resource "kubernetes_namespace" "httpd-healthcheck" {
  metadata {
    name = "httpd-healthcheck"
    labels = {
      istio-injection = "enabled"
    }
  }
}

data "kubectl_path_documents" "httpd_healthcheck" {
  pattern          = "../../kubernetes/httpd-healthcheck/*.yml"
  disable_template = true
}

resource "kubectl_manifest" "httpd_healthcheck" {
  for_each  = data.kubectl_path_documents.httpd_healthcheck.manifests
  yaml_body = each.value

  depends_on = [
    kubernetes_namespace.httpd-healthcheck
  ]
}
