# Create ElasticSearch secrets
data "kubectl_path_documents" "elasticsearch_secrets" {
  pattern = "../kubernetes/logging/elastic-*-secret.y*ml"
}
resource "kubectl_manifest" "elasticsearch_secrets" {
  count     = length(data.kubectl_path_documents.elasticsearch_secrets.documents)
  yaml_body = element(data.kubectl_path_documents.elasticsearch_secrets.documents, count.index)
}

# Deploy ElasticSearch instance
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = var.elastic_stack_repository
  chart      = "elasticsearch"
  namespace  = var.elastic_stack_namespace
  version    = var.elastic_stack_version

  values = [
    "${file("../kubernetes/logging/values-elasticsearch.yml")}"
  ]

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.elasticsearch_secrets
  ]
}

# Deploy Kibana instance
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = var.elastic_stack_repository
  chart      = "kibana"
  namespace  = var.elastic_stack_namespace
  version    = var.elastic_stack_version

  values = [
    "${file("../kubernetes/logging/values-kibana.yml")}"
  ]

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.elasticsearch_secrets,
    helm_release.elasticsearch
  ]
}

# Deploy Filebeat
resource "helm_release" "filebeat" {
  name       = "filebeat"
  repository = var.elastic_stack_repository
  chart      = "filebeat"
  namespace  = var.elastic_stack_namespace
  version    = var.elastic_stack_version

  values = [
    "${file("../kubernetes/logging/values-filebeat.yml")}"
  ]

  depends_on = [
    kubectl_manifest.calico,
    kubectl_manifest.elasticsearch_secrets,
    helm_release.elasticsearch
  ]
}
