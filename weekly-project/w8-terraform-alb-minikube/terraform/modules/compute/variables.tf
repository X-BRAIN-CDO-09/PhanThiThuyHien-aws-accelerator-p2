variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "ec2_security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "node_port" {
  type = number
}

variable "app_image" {
  type = string
}

variable "app_replicas" {
  type = number
}

variable "frontend_bucket" {
  description = "S3 bucket name that stores frontend index.html"
  type        = string
}

variable "frontend_key" {
  description = "S3 object key for frontend index.html"
  type        = string
}