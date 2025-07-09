terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "terraform-homelab-remote-state"
    key            = "resources-core.tfstate"
    dynamodb_table = "terraform-homelab-remote-state-lock"
    encrypt        = true
    profile        = "terraform_homelab"
  }
}
