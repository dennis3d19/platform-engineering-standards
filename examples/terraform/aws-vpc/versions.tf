terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configured via -backend-config=backend.hcl (not committed)
  # backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags_common
  }
}
