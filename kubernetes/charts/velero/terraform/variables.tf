variable "aws_region" {
  description = "AWS region to deploy resources to"
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "AWS profile to use to provision resources"
  type        = string
  default     = "default"
}

variable "local_prefix" {
  description = "Prefix to use for resources"
  type        = string
  default     = "kubernetes-homelab"
}
