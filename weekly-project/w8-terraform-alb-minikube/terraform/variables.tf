variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project_name" {
  type    = string
  default = "minikube-alb-lab"
}

variable "environment" {
  type    = string
  default = "dev"
}

# vpc, subnet
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.10.0/24"
}

# ec2 
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "node_port" {
  type    = number
  default = 30080
}

# app
variable "app_image" {
  type    = string
  default = "nginx:1.27"
}

variable "app_replicas" {
  type    = number
  default = 1
}

