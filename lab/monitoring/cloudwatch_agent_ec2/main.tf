terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0" # Keeps you safe from connection bugs introduced in 5.65+
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
    values = ["al2023-ami-2023.*-x86_64"] 
  }
}

# 1. Create a Role that an EC2 instance can assume
resource "aws_iam_role" "ec2_cw_role" {
  name = "EC2CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Attach the official AWS CloudWatchAgentServerPolicy to that Role
resource "aws_iam_role_policy_attachment" "cw_policy_attach" {
  role       = aws_iam_role.ec2_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM Session Manager policy
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ec2_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. Create the Instance Profile container
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2CloudWatchInstanceProfile"
  role = aws_iam_role.ec2_cw_role.name
}

# --- IMPROVEMENT: Store the CloudWatch Agent configuration in SSM Parameter Store ---
resource "aws_ssm_parameter" "cw_agent_config" {
  name        = "AmazonCloudWatch-linux-agent-config"
  type        = "String"
  description = "CloudWatch agent configuration for Linux EC2 metrics"
  
  # You can easily add or remove metrics in this clean block below:
  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user                 = "cwagent"
    }
    metrics = {
      metrics_collected = {
        disk = {
          measurement                 = ["disk_used_percent"]
          metrics_collection_interval = 60
          resources                   = ["*"]
        }
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 60
        }
      }
    }
  })
}

resource "aws_instance" "my_monitored_server" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # --- CLEANER USER DATA: Fetches config cleanly from SSM ---
  user_data = <<-EOF
              #!/bin/bash
              
              # 1. Install the Agent Package
              dnf install amazon-cloudwatch-agent -y || yum install amazon-cloudwatch-agent -y

              # 2. Start the Agent using the configuration saved in the SSM Parameter Store
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -s \
                -c ssm:${aws_ssm_parameter.cw_agent_config.name}
              
              # 3. Ensure the service starts automatically if the server reboots
              systemctl enable amazon-cloudwatch-agent
              EOF

  tags = {
    Name = "CloudWatch-Agent-Lab"
  }
}


