################################################################################################################################
# ecs/variables.tf
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
