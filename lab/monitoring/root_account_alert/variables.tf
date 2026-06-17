variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "alert_email" {
  type        = string
  description = "Email address that receives root account login alerts"
  default     = "thuyhienphanthi2004@gmail.com"
}

variable "trail_name" {
  type    = string
  default = "security-root-login-trail"
}