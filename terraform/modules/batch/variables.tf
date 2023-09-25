################################################################################################################################
# batch/variables.tf
# 
# These values are passed as input variables to batch resources.
################################################################################################################################

// project

variable "aws_region" {
  description = "Region (e.g. us-east-1, us-east-2)"
  type        = string
}

variable "environment_name" {
  description = "Environment (e.g., dev, prod, staging)"
  type        = string
}

variable "project_name" {
  description = "Name of this project, used for resource naming and tagging."
  type        = string
}

// network

variable "vpc_default_sg" {
  description = "The default security group of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of IDs of private subnets"
  type        = list(string)
}
