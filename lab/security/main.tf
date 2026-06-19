provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project   = var.project_name
        ManagedBy = "Terraform"
        Purpose   = "Amazon Macie sensitive-data detection lab"
      },
      var.tags
    )
  }
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = coalesce(
    var.bucket_name,
    "${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  )

  sample_files = {
    "synthetic-customer-records.csv" = "text/csv"
    "readme.txt"                     = "text/plain"
  }

  # Including the content hash in the Macie job name causes Terraform to create
  # a fresh one-time job when the managed sample data changes.
  sample_content_hash = sha256(join("", [
    for filename in sort(keys(local.sample_files)) :
    filemd5("${path.module}/sample-data/${filename}")
  ]))
}
