terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source = "hashicorp/archive"
    }
    null = {
      source = "hashicorp/null"
    }
  }

  required_version = ">= 1.3.7"
}

provider "aws" {
  region  = "us-east-1"
  profile = "tutorial-terraform-profile"
  default_tags {
    tags = {
      app = "tutorial-terraform"
    }
  }
}

module "example1" {
  source = "./services/example1/infrastructure"
  # Pass any required variables to the module
}
