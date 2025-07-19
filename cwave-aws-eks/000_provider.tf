## AWS Provider 설정
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}
## 버전 설정
terraform {
  backend "s3" {
    bucket         = "cwave-terraform-state-subin"
    key            = "eks/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "cwave-terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}