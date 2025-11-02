variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "csv-processor"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
}