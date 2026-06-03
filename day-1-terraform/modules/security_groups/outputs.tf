output "lambda_sg_id" {
  description = "Lambda Security Group ID"
  value       = aws_security_group.lambda_sg.id
}

output "vpc_endpoint_sg_id" {
  description = "VPC Endpoint Security Group ID"
  value       = aws_security_group.vpc_endpoint_sg.id
}
