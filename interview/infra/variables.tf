# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS Access Key ID"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS Secret Access Key"
  type        = string
}

