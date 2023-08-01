terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "personal-brainstorm"
}

provider "awscc" {
  region = "us-east-1"
  profile = "personal-brainstorm"
}