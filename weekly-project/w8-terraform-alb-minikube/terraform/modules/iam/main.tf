locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name = "ec2-ssm-role"

  # Only allow ec2 to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# In aws, we cannot assign iam role directly to ec2
# we assign via iam instance profile
resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_iam_role_policy" "read_frontend_s3" {
  name = "read-frontend-s3"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${var.frontend_bucket_arn}/*"
      }
    ]
  })
}