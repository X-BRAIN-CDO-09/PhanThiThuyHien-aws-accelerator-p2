output "app_url" {
  description = "Application URL"
  value       = module.alb.app_url
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID running minikube"
  value       = module.compute.instance_id
}

output "ec2_private_ip" {
  description = "Private IP of EC2 instance"
  value       = module.compute.private_ip
}