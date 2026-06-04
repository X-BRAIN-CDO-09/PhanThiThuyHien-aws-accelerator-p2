output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "app_url" {
  value = "http://${aws_lb.app.dns_name}"
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}