terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state is strongly recommended over local .tfstate once you're
  # past pure practice runs - it prevents state loss and lets you (or
  # teammates) safely re-apply from any machine. Uncomment and fill in
  # once you've created the S3 bucket + DynamoDB lock table:
  #
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket-name"
  #   key            = "devops-project/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}
