###################################################################################################################################
# alb/variables.tf
###################################################################################################################################

// project

variable "environment_name" {
  description = "Environment (e.g., dev, prod, staging)"
  type        = string
}

variable "project_name" {
  description = "Name of this project, used for resource naming and tagging."
  type        = string
}

// network

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

