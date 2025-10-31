terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
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
