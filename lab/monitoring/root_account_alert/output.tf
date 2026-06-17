output "sns_topic_arn" {
  value = aws_sns_topic.security_alerts.arn
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.cloudtrail.name
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.root_account_login.alarm_name
}