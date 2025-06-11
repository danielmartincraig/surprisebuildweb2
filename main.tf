terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88"
    }
  }
  cloud { 
    organization = "surprisebuild"
    workspaces { 
      name = "surprisebuildweb" 
    } 
  } 
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "surprisebuildweb_public_repo" {
  repository_name = "surprisebuildweb"

  catalog_data {
    description = "Public ECR repository for surprisebuildweb"
  }
}