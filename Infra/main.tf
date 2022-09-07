terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "4.25.0"
    }
  }
  backend "s3" {
    profile = "trabalho-devops-wr"
    bucket  = "s3-trabalho-wr"
    key     = "state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "trabalho-devops-wr"
}
