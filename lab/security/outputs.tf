output "s3_bucket_name" {
  description = "S3 bucket scanned by Amazon Macie."
  value       = aws_s3_bucket.sensitive_data.id
}

output "macie_classification_job_id" {
  description = "ID of the one-time Amazon Macie classification job."
  value       = aws_macie2_classification_job.sensitive_data.id
}

output "macie_console_url" {
  description = "AWS Console URL for Amazon Macie findings in the selected Region."
  value       = "https://${var.aws_region}.console.aws.amazon.com/macie/home?region=${var.aws_region}#/findings"
}

output "sns_topic_arn" {
  description = "SNS topic that receives Macie finding events from EventBridge."
  value       = aws_sns_topic.macie_findings.arn
}

output "email_subscription_status" {
  description = "SNS email subscriptions remain pending until the recipient clicks the confirmation link."
  value       = "Check ${var.alert_email} and confirm the AWS Notifications subscription."
}

