terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.76.1"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

