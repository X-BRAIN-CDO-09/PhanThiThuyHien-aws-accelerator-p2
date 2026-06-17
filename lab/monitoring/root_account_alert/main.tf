terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  trail_arn = "arn:aws:cloudtrail:${local.region}:${local.account_id}:trail/${var.trail_name}"
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-root-login-${local.account_id}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = local.trail_arn
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${local.account_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "AWS:SourceArn" = local.trail_arn
          }
        }
      }
    ]
  })
}

# CloudWatch Logs for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/root-login-alert"
  retention_in_days = 90
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  name = "cloudtrail-to-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch" {
  name = "cloudtrail-to-cloudwatch-logs-policy"
  role = aws_iam_role.cloudtrail_to_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_to_cloudwatch.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs,
    aws_iam_role_policy.cloudtrail_to_cloudwatch
  ]
}

# SNS notification
resource "aws_sns_topic" "security_alerts" {
  name = "security-root-login-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_policy" "security_alerts" {
  arn = aws_sns_topic.security_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudWatchAlarmPublish"
        Effect = "Allow"

        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }

        Action   = "SNS:Publish"
        Resource = aws_sns_topic.security_alerts.arn

        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}

# CloudWatch Metric Filter
resource "aws_cloudwatch_log_metric_filter" "root_account_login" {
  name           = "RootAccountLogin"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  # Same idea as the slide:
  # Detect real root account activity, excluding AWS service events.
  pattern = "{ ($.userIdentity.type = \"Root\") && ($.eventType != \"AwsServiceEvent\") }"

  metric_transformation {
    name      = "RootAccountLoginCount"
    namespace = "Security"
    value     = "1"
  }
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "root_account_login" {
  alarm_name          = "RootAccountLoginDetected"
  alarm_description   = "Alert when AWS root account is used."
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = "Security"
  metric_name = "RootAccountLoginCount"
  statistic   = "Sum"

  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.security_alerts.arn
  ]

  depends_on = [
    aws_cloudwatch_log_metric_filter.root_account_login,
    aws_sns_topic_policy.security_alerts
  ]
}