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
          Service = "://amazonaws.com"
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

# 3. Create the Instance Profile container (this is what attaches to the EC2 code)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2CloudWatchInstanceProfile"
  role = aws_iam_role.ec2_cw_role.name
}

resource "aws_instance" "my_monitored_server" {
  ami                  = "ami-0c55b159cbfafe1f0" # Replace with a valid Amazon Linux AMI for your region
  instance_type        = "t3.micro"
  
  # Attaches the IAM permissions from Step 1
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Automation script for Steps 1, 2, 3, and 4 on the slide
  user_data = <<-EOF
              #!/bin/bash
              
              # --- SLIDE STEP 1: Install the Agent Package ---
              dnf install amazon-cloudwatch-agent -y || yum install amazon-cloudwatch-agent -y

              # --- SLIDE STEP 2: Create the Wizard Configuration File ---
              # The wizard creates a json file. We write a basic version directly to the correct spot:
              cat << 'JSON' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
              {
                "agent": {
                  "metrics_collection_interval": 60,
                  "run_as_user": "cwagent"
                },
                "metrics": {
                  "metrics_collected": {
                    "disk": {
                      "measurement": ["disk_used_percent"],
                      "metrics_collection_interval": 60,
                      "resources": ["*"]
                    },
                    "mem": {
                      "measurement": ["mem_used_percent"],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }
              JSON

              # --- SLIDE STEP 3: Start the Agent ---
              # Fetch the config file and jumpstart the background service process
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
              
              # Enable systemctl so it boots back up automatically if the server reboots
              systemctl enable amazon-cloudwatch-agent
              EOF

  tags = {
    Name = "CloudWatch-Agent-Lab"
  }
}



