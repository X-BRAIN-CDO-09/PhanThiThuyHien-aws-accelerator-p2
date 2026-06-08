variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "state_bucket_name" {
  type = string
}

variable "lock_table_name" {
  type    = string
  default = "terraform-state-lock"
}