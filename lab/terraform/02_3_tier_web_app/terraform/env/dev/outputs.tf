output "public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = module.ec2.public_ip
}

output "public_dns" {
  description = "Public DNS of the web EC2 instance"
  value       = module.ec2.public_dns
}
