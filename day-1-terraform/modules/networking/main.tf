# Subnets
resource "aws_subnet" "private_app_az1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.az1_private_app_cidr
  availability_zone = var.availability_zones[0]

  tags = merge(
    {
      Name        = "${var.project_name}-vpc-az1-private-app"
      Environment = var.environment
      Tier        = "Private-Application"
    },
    var.tags
  )
}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.az2_private_app_cidr
  availability_zone = var.availability_zones[1]

  tags = merge(
    {
      Name        = "${var.project_name}-vpc-az2-private-app"
      Environment = var.environment
      Tier        = "Private-Application"
    },
    var.tags
  )
}

# Route Tables
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name        = "${var.project_name}-private-route-table"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private.id
}

# Network ACLs
resource "aws_network_acl" "private" {
  vpc_id = var.vpc_id
  subnet_ids = [
    aws_subnet.private_app_az1.id,
    aws_subnet.private_app_az2.id
  ]

  # Inbound: From internal VPC network (HTTPS)
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 443
    to_port    = 443
  }

  # Inbound: Receive responses from other AWS services (ephemeral ports)
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound: Call HTTPS (port 443) to reach Bedrock/DynamoDB
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Outbound: Response traffic to internal VPC (ephemeral ports)
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(
    {
      Name        = "${var.project_name}-private-nacl"
      Environment = var.environment
    },
    var.tags
  )
}
