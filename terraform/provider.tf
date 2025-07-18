terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
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
