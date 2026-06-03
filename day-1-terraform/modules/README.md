# Terraform Modules

This directory contains reusable Terraform modules for AWS infrastructure components.

## Module Directory Structure

Each module follows the standard Terraform module structure with:

```
module_name/
├── main.tf          # Resource definitions
├── variables.tf     # Input variable definitions
└── outputs.tf       # Output value definitions
```

## Available Modules

### vpc

Core VPC configuration with DNS support.

**Usage:**

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  project_name         = "my-project"
  environment          = "dev"
}
```

### networking

Private subnets, route tables, and network ACLs.

**Usage:**

```hcl
module "networking" {
  source = "./modules/networking"

  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr
  availability_zones  = ["us-west-2a", "us-west-2b"]
  az1_private_app_cidr = "10.0.8.0/22"
  az2_private_app_cidr = "10.0.12.0/22"
  project_name        = "my-project"
  environment         = "dev"
}
```

### security_groups

Lambda and VPC endpoint security groups.

**Usage:**

```hcl
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id       = module.vpc.vpc_id
  project_name = "my-project"
  environment  = "dev"
}
```

### vpc_endpoints

VPC endpoints for Bedrock, DynamoDB, and S3.

**Usage:**

```hcl
module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id                          = module.vpc.vpc_id
  aws_region                      = var.aws_region
  subnet_ids                      = module.networking.subnet_ids
  route_table_ids                 = [module.networking.route_table_id]
  vpc_endpoint_security_group_ids = [module.security_groups.vpc_endpoint_sg_id]
  project_name                    = "my-project"
  environment                     = "dev"

  enable_bedrock_endpoint   = true
  enable_dynamodb_endpoint  = true
  enable_s3_endpoint        = true
}
```

## Best Practices

1. **Inputs**: Every module should have well-documented input variables with types and defaults
2. **Outputs**: Expose all meaningful resource IDs and attributes
3. **Tagging**: Support common tags for resource organization
4. **Flexibility**: Use variables and conditionals for optional features
5. **Documentation**: Include README files for complex modules

## Module Dependencies

```
vpc
  ↓
networking  ← security_groups
  ↓
vpc_endpoints (uses outputs from networking & security_groups)
```

## Testing Modules

To test individual modules, create a temporary `main.tf`:

```hcl
module "test_vpc" {
  source = "./modules/vpc"

  vpc_cidr     = "10.0.0.0/16"
  project_name = "test"
  environment  = "dev"
}

output "test_vpc_id" {
  value = module.test_vpc.vpc_id
}
```

Then run:

```bash
terraform init
terraform plan
```
