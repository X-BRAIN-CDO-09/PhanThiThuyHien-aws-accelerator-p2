terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for common tags and configuration
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  project_name          = var.project_name
  environment           = var.environment
  tags                  = local.common_tags
}

# Networking Module (Subnets, Route Tables, NACLs)
module "networking" {
  source = "./modules/networking"

  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = module.vpc.vpc_cidr
  project_name         = var.project_name
  environment          = var.environment
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  az1_private_app_cidr = var.vpc_az1_private_app_cidr
  az2_private_app_cidr = var.vpc_az2_private_app_cidr
  tags                 = local.common_tags

  depends_on = [module.vpc]
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id        = module.vpc.vpc_id
  project_name  = var.project_name
  environment   = var.environment
  tags          = local.common_tags

  depends_on = [module.vpc]
}

# VPC Endpoints Module
module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id                           = module.vpc.vpc_id
  aws_region                       = var.aws_region
  subnet_ids                       = module.networking.subnet_ids
  route_table_ids                  = [module.networking.route_table_id]
  vpc_endpoint_security_group_ids  = [module.security_groups.vpc_endpoint_sg_id]
  project_name                     = var.project_name
  environment                      = var.environment
  enable_bedrock_endpoint          = var.enable_bedrock_endpoint
  enable_dynamodb_endpoint         = var.enable_dynamodb_endpoint
  enable_s3_endpoint               = var.enable_s3_endpoint
  tags                             = local.common_tags

  depends_on = [module.networking, module.security_groups]
}
