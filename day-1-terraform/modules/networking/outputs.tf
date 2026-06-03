output "subnet_az1_id" {
  description = "AZ-1 Private Subnet ID"
  value       = aws_subnet.private_app_az1.id
}

output "subnet_az2_id" {
  description = "AZ-2 Private Subnet ID"
  value       = aws_subnet.private_app_az2.id
}

output "route_table_id" {
  description = "Route table ID"
  value       = aws_route_table.private.id
}

output "subnet_ids" {
  description = "List of all subnet IDs"
  value       = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
}
