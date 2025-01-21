# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0cd633458f59bf476"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
  default     = ["subnet-09189d667fafb9700", "subnet-0444675e076182887"]
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
  default     = ["subnet-0d9e3d6f71b59400e", "subnet-0aea783dd75edd3f6"]
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}
