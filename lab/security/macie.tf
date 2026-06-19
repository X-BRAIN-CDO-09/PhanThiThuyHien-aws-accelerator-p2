resource "aws_macie2_account" "this" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# Macie builds an S3 inventory asynchronously after it is enabled. Waiting here
# avoids a common first-apply failure where a brand-new bucket is not yet known
# to the Macie classification-job API.
resource "time_sleep" "macie_inventory" {
  create_duration = var.macie_inventory_wait

  triggers = {
    bucket_arn          = aws_s3_bucket.sensitive_data.arn
    macie_account_id    = aws_macie2_account.this.id
    sample_content_hash = local.sample_content_hash
  }

  depends_on = [aws_s3_object.sample_data]
}

resource "aws_macie2_classification_job" "sensitive_data" {
  name                = "${var.project_name}-${substr(local.sample_content_hash, 0, 8)}"
  description         = "One-time sensitive-data discovery job for the Terraform Macie lab"
  job_type            = "ONE_TIME"
  sampling_percentage = 100

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sensitive_data.id]
    }
  }

  # Install the complete alert path before starting the one-time scan. The SNS
  # email still has to be confirmed by its recipient before email can be sent.
  depends_on = [
    time_sleep.macie_inventory,
    aws_cloudwatch_event_target.macie_findings,
    aws_sns_topic_subscription.email
  ]
}
