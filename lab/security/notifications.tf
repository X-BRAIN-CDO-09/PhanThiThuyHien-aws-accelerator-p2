resource "aws_sns_topic" "macie_findings" {
  name = "${var.project_name}-findings"

  tags = {
    Name = "${var.project_name}-findings"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.macie_findings.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = "${var.project_name}-findings"
  description = "Send Amazon Macie findings to the lab SNS topic"

  event_pattern = jsonencode({
    source        = ["aws.macie"]
    "detail-type" = ["Macie Finding"]
  })

  tags = {
    Name = "${var.project_name}-findings"
  }
}

data "aws_iam_policy_document" "sns_topic" {
  policy_id = "${var.project_name}-sns-policy"

  statement {
    sid    = "AllowAccountOwner"
    effect = "Allow"

    actions = [
      "SNS:AddPermission",
      "SNS:DeleteTopic",
      "SNS:GetTopicAttributes",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:Subscribe"
    ]

    resources = [aws_sns_topic.macie_findings.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowEventBridgePublish"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.macie_findings.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.macie_findings.arn]
    }
  }
}

resource "aws_sns_topic_policy" "macie_findings" {
  arn    = aws_sns_topic.macie_findings.arn
  policy = data.aws_iam_policy_document.sns_topic.json
}

resource "aws_cloudwatch_event_target" "macie_findings" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "SendToSns"
  arn       = aws_sns_topic.macie_findings.arn

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 10
  }

  depends_on = [aws_sns_topic_policy.macie_findings]
}
