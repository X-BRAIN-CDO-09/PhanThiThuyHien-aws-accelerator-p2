terraform {
  backend "s3" {
    bucket         = "terraform-3tier-319110095771-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}