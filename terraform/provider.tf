terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/custom-contexts/hl-config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/custom-contexts/hl-config"
}

provider "kubectl" {
  apply_retry_count = 5
  config_path       = "~/.kube/custom-contexts/hl-config"
  load_config_file  = true
}
