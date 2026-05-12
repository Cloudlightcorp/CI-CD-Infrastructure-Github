############################################################
# TERRAFORM BACKEND
############################################################

terraform {
  backend "s3" {
    bucket = "terraform-codepipeline-shared-bucket"
    key    = "GIT-OnlineMobileStore/terraform/state.tfstate"
    region = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

############################################################
# PROVIDER
############################################################

provider "aws" {
  region = var.region
}
