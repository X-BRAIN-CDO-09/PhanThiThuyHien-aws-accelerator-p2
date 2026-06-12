terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0" # Keeps you safe from the connection bugs introduced in 5.65+
    }
  }
}
provider "aws" {
	region = var.aws_region
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    # Update this value to target the core production pattern
    values = ["al2023-ami-2023.*-x86_64"] 
  }
}

# 1. Create SNS topic 
resource "aws_sns_topic" "cpu_alert_topic" {
	name = "80-high-cpu-alerts"
  
}
# 2. Subscribe your email to the SNS Topic
resource "aws_sns_topic_subscription" "email_sub" {
	topic_arn = aws_sns_topic.cpu_alert_topic.arn
	protocol = "email"
	endpoint = "thuyhienphanthi2004@gmail.com"
}

# 3. Create multiple ec2 
resource "aws_instance" "web_servers" {
	for_each = toset(["web-1, web-2, web-3"])
	ami           = data.aws_ami.amazon_linux_2023.id
  	instance_type = "t3.micro"

	# This script runs automatically when the server starts
  	user_data = <<-EOF
              #!/bin/bash
              # 1. Update the package manager
              dnf update -y || yum update -y
              
              # 2. Install the stress test tool
              dnf install stress -y || yum install stress -y
              
              # 3. Run stress on 2 CPU cores for 15 minutes (900 seconds)
              stress --cpu 2 --timeout 900s
              EOF

	tags = {
		Name = "Test CPU Alerts"
	}
}

# 4. Create the CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
	for_each = aws_instance.web_servers

	alarm_name          = "ec2-high-cpu-usage"
	comparison_operator = "GreaterThanThreshold"
	threshold           = 80
	  
	# Matches "Period: 5 minutes" (300 seconds = 5 minutes)
	period              = 300           
	  
	# Matches "Evaluation: 1 out of 1 datapoints"
	evaluation_periods  = 1             
	datapoints_to_alarm = 1             

  	metric_name         = "CPUUtilization"
  	namespace           = "AWS/EC2"
  	statistic           = "Average"

	dimensions = {
		InstanceId = each.value.id # Targets one specific instance per loop
	}

	alarm_description = "Monitors CPU for EC2 instance ${each.key}"

	# 1. Triggers when CPU goes OVER 80% (Alarm State)
	alarm_actions = [aws_sns_topic.cpu_alert_topic.arn]

	ok_actions        = [aws_sns_topic.cpu_alert_topic.arn]
}
