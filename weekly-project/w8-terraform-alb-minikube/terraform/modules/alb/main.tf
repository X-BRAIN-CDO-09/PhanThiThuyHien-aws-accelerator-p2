locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb" "app" {
  name               = "alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [var.alb_security_group_id]
  subnets         = var.public_subnet_id

  tags = merge(local.common_tags, {
    Name = "alb"
  })
}

resource "aws_lb_target_group" "app" {
  name        = "tg"
  port        = var.node_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = merge(local.common_tags, {
    Name = "tg"
  })
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.target_instance_id
  port             = var.node_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}