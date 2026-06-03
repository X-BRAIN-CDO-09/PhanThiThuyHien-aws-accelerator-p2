output "bedrock_endpoint_id" {
  description = "Bedrock Runtime VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.bedrock_runtime[0].id, null)
}

output "dynamodb_endpoint_id" {
  description = "DynamoDB Gateway VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.dynamodb[0].id, null)
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}
