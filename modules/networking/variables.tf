# modules/networking/variables.tf
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_route_table_id" {
  description = "ID of the existing private route table"
  type        = string
  default     = "rtb-00a0902328fdb2b58"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

