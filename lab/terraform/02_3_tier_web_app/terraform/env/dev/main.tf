module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
}

module "security_group" {
  source = "../../modules/security_group"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
}

module "rds" {
  source = "../../modules/rds"

  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_group.rds_sg_id

  db_instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "ec2" {
  source = "../../modules/ec2"

  project_name     = var.project_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name
  public_subnet_id = module.vpc.public_subnet_ids[0]
  ec2_sg_id        = module.security_group.ec2_sg_id

  db_host     = module.rds.rds_endpoint
  db_name     = var.db_name
  db_user     = var.db_username
  db_password = var.db_password
}