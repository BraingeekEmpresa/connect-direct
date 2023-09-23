terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.12"
      version = ">= 4.65"
     }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "pruebaterraform"
    key    = "terraform.tfstate"
    region = "us-west-2"     
  }  
}


