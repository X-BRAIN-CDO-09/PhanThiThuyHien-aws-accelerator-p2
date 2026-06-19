resource "aws_s3_bucket" "sensitive_data" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy_bucket

  tags = {
    Name = local.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "sensitive_data" {
  bucket = aws_s3_bucket.sensitive_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "sensitive_data" {
  bucket = aws_s3_bucket.sensitive_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sensitive_data" {
  bucket = aws_s3_bucket.sensitive_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "sensitive_data" {
  bucket = aws_s3_bucket.sensitive_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "sample_data" {
  for_each = local.sample_files

  bucket                 = aws_s3_bucket.sensitive_data.id
  key                    = "sample-data/${each.key}"
  source                 = "${path.module}/sample-data/${each.key}"
  etag                   = filemd5("${path.module}/sample-data/${each.key}")
  content_type           = each.value
  server_side_encryption = "AES256"

  depends_on = [
    aws_s3_bucket_ownership_controls.sensitive_data,
    aws_s3_bucket_public_access_block.sensitive_data,
    aws_s3_bucket_server_side_encryption_configuration.sensitive_data,
    aws_s3_bucket_versioning.sensitive_data
  ]
}
