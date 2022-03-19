terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "terraform-homelab-remote-state"
    key            = "velero.tfstate"
    dynamodb_table = "terraform-homelab-remote-state-lock"
    encrypt        = true
  }
}
