terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "6.48.0"
		}
	}
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "static_web" {
	bucket = "01-learn-terraform"

	# Delete all nested objects in the bucket 
	# before destroying the bucket itself
	force_destroy = true 

	# tags = local.tags	
}

# resource "aws_s3_bucket_acl" "static" {
# 	bucket = aws_s3_bucket.static_web.id
# 	acl = "public-read"
# }
# Bucket owner automatically owns every single object uploaded to the bucket
# regardless of who uploaded it
resource "aws_s3_bucket_ownership_controls" "static" {
  bucket = aws_s3_bucket.static_web.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Explicitly ALLOW public access policies on this bucket
resource "aws_s3_bucket_public_access_block" "static" {
	bucket = aws_s3_bucket.static_web.id

	block_public_acls       = true
	block_public_policy     = false # Crucial: Allows the public bucket policy to work
	ignore_public_acls      = true
	restrict_public_buckets = false # Crucial: Allows the bucket to be public
}

resource "aws_s3_bucket_website_configuration" "static" {
	bucket = aws_s3_bucket.static_web.bucket

	# Static file
	index_document {
		suffix = "index.html"
	}

	# Include this file in static_web bucket
	error_document {
		key = "error.html"
	}

}

# Create IAM policy
data "aws_iam_policy_document" "static" {
	statement {
	  actions = ["s3:GetObject"]
	  
	  # All objects in this bucket
	  resources = ["${aws_s3_bucket.static_web.arn}/*"]

	  # Who can access?
	  # Anyone on the Internet
	  principals {
		type = "*"
		identifiers = [ "*" ]
	  }
	}
}

resource "aws_s3_bucket_policy" "static" {
	bucket = aws_s3_bucket.static_web.id
	policy = data.aws_iam_policy_document.static.json

	depends_on = [ 
		aws_s3_bucket_public_access_block.static,
		aws_s3_bucket_ownership_controls.static
	]
}