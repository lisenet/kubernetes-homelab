terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
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
