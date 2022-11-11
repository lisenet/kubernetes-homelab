variable "elastic_stack_repository" {
  description = "Elastic stack Helm repository"
  type        = string
  default     = "https://helm.elastic.co"
}

variable "elastic_stack_version" {
  description = "Elastic stack Helm chart version"
  type        = string
  default     = "7.17.1"
}

variable "elastic_stack_namespace" {
  description = "Elastic stack Kubernetes namespace"
  type        = string
  default     = "logging"
}

