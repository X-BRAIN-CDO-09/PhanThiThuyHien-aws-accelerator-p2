locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for public Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "alb-sg"
  })
}

resource "aws_security_group" "ec2" {
  name        = "ec2-sg"
  description = "Security group for EC2 Minikube node"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "ec2-sg"
  })
}

# Internet -> ALB:80
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  description       = "Allow HTTP from Internet to ALB"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ALB -> EC2:30080
resource "aws_security_group_rule" "alb_egress_to_ec2_nodeport" {
  type              = "egress"
  description       = "Allow ALB to forward traffic to EC2 NodePort"
  security_group_id = aws_security_group.alb.id

  from_port   = var.node_port
  to_port     = var.node_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ALB outbound should allow general traffic for AWS-managed control plane provisioning
resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  description       = "Allow ALB outbound traffic for managed provisioning and health checks"
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# EC2 accepts NodePort only from ALB
resource "aws_security_group_rule" "ec2_ingress_from_alb_nodeport" {
  type              = "ingress"
  description       = "Allow NodePort traffic from ALB only"
  security_group_id = aws_security_group.ec2.id

  from_port                = var.node_port
  to_port                  = var.node_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

# EC2 -> Internet through NAT Gateway
resource "aws_security_group_rule" "ec2_egress_all" {
  type              = "egress"
  description       = "Allow EC2 outbound Internet access through NAT Gateway"
  security_group_id = aws_security_group.ec2.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}