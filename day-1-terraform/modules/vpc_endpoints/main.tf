# Bedrock Runtime Interface VPC Endpoint
resource "aws_vpc_endpoint" "bedrock_runtime" {
  count               = var.enable_bedrock_endpoint ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids           = var.subnet_ids
  security_group_ids   = var.vpc_endpoint_security_group_ids

  tags = merge(
    {
      Name        = "${var.project_name}-bedrock-runtime-endpoint"
      Environment = var.environment
    },
    var.tags
  )
}

# DynamoDB Gateway VPC Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  count             = var.enable_dynamodb_endpoint ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(
    {
      Name        = "${var.project_name}-dynamodb-endpoint"
      Environment = var.environment
    },
    var.tags
  )
}

# S3 Gateway VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_s3_endpoint ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(
    {
      Name        = "${var.project_name}-s3-endpoint"
      Environment = var.environment
    },
    var.tags
  )
}
