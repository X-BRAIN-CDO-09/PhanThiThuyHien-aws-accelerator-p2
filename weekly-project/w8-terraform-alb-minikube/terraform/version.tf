terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # Use cloudinit provider to generate EC2 instance user_data
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }

    # Use random provider to generate unique s3 bucket name
    # random_id.frontend_suffix
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}