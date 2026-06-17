output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.my_monitored_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_monitored_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.my_monitored_server.public_dns
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.my_monitored_server.private_ip
}

output "instance_private_dns" {
  description = "Private DNS name / host dimension used by CWAgent"
  value       = aws_instance.my_monitored_server.private_dns
}

output "iam_role_name" {
  description = "IAM role attached to EC2 for CloudWatch Agent"
  value       = aws_iam_role.ec2_cw_role.name
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "cloudwatch_agent_namespace" {
  description = "CloudWatch Agent custom metric namespace"
  value       = "CWAgent"
}

output "cloudwatch_agent_metrics" {
  description = "Metrics configured in CloudWatch Agent"
  value = [
    "mem_used_percent",
    "disk_used_percent"
  ]
}

output "ssh_command" {
  description = "SSH command for Amazon Linux 2023"
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.my_monitored_server.public_ip}"
}