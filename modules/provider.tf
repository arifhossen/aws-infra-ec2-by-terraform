terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0" # or whatever version you're using
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile # Use the aws_profile variable
}

