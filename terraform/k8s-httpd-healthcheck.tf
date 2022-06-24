data "kubectl_path_documents" "httpd_healthcheck" {
  pattern          = "../httpd-healthcheck/*.y*ml"
  disable_template = true
}

resource "kubectl_manifest" "httpd_healthcheck" {
  count     = length(data.kubectl_path_documents.httpd_healthcheck.documents)
  yaml_body = element(data.kubectl_path_documents.httpd_healthcheck.documents, count.index)
}
