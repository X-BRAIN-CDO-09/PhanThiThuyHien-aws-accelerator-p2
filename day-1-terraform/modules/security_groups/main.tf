# Security Group for Lambda Backend
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Backend Lambda functions"
  vpc_id      = var.vpc_id

  # Egress: Allow all traffic to reach Bedrock and DynamoDB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic to AWS services"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-lambda-sg"
      Environment = var.environment
    },
    var.tags
  )
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.project_name}-vpc-endpoint-sg"
  description = "Security group for Interface VPC Endpoints"
  vpc_id      = var.vpc_id

  # Ingress: Only allow Lambda functions to access endpoints
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
    description     = "Allow Lambda security group to access VPC endpoints"
  }

  # Egress: Allow all traffic (responses)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic for responses"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-vpc-endpoint-sg"
      Environment = var.environment
    },
    var.tags
  )
}
