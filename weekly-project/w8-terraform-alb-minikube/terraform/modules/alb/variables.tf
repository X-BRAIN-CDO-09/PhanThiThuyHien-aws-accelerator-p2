variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "target_instance_id" {
  type = string
}

variable "node_port" {
  type = number
}