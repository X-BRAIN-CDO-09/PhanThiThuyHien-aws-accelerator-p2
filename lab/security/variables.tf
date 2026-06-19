variable "aws_region" {
  description = "AWS Region in which to deploy the lab. Amazon Macie must be available in this Region."
  type        = string
  default     = "ap-southeast-1"
}

variable "alert_email" {
  description = "Email address that will receive Amazon Macie finding notifications. AWS requires the recipient to confirm the SNS subscription."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "project_name" {
  description = "Lowercase name used to identify and tag the lab resources."
  type        = string
  default     = "macie-sensitive-data-lab"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 30 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    )
    error_message = "project_name must be 3-30 lowercase letters, numbers, or hyphens and must start and end with a letter or number."
  }
}

variable "bucket_name" {
  description = "Optional globally unique S3 bucket name. When null, the name is derived from the project, AWS account ID, and Region."
  type        = string
  default     = null

  validation {
    condition = var.bucket_name == null ? true : (
      length(var.bucket_name) >= 3 &&
      length(var.bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    )
    error_message = "bucket_name must be null or a valid 3-63 character S3 bucket name."
  }
}

variable "force_destroy_bucket" {
  description = "Allow terraform destroy to delete the lab bucket and all object versions. Keep true for a disposable lab."
  type        = bool
  default     = true
}

variable "macie_inventory_wait" {
  description = "Time to wait for Macie to discover the new S3 bucket before creating the classification job. Increase this if AWS reports that the bucket is not yet in the Macie inventory."
  type        = string
  default     = "2m"
}

variable "tags" {
  description = "Additional tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}
