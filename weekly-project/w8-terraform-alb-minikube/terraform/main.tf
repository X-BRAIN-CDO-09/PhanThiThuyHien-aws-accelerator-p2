module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  node_port    = var.node_port
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  frontend_bucket_arn = aws_s3_bucket.frontend.arn
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  private_subnet_id     = module.network.private_subnet_id
  ec2_security_group_id = module.security.ec2_security_group_id
  instance_profile_name = module.iam.instance_profile_name

  instance_type = var.instance_type
  node_port     = var.node_port
  app_image     = var.app_image
  app_replicas  = var.app_replicas

  frontend_bucket = aws_s3_bucket.frontend.id
  frontend_key    = aws_s3_object.frontend_index.key

  depends_on = [
    module.network,
    module.iam,
    aws_s3_object.frontend_index
  ]
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_id      = module.network.public_subnet_id
  alb_security_group_id = module.security.alb_security_group_id

  target_instance_id = module.compute.instance_id
  node_port          = var.node_port
}