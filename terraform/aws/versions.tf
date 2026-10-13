terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional, once you are comfortable: store state in S3 instead of locally.
  # backend "s3" {
  #   bucket         = "<your-unique-bucket>"
  #   key            = "devops-lab/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "<lock-table>"
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
    }
  }
}
