################################################################################################################################
# dev/variables.tf
#
# This file acts as the entrypoint for drilling environment variables down to child modules as input parameters.
# 
# Learn more by reading the docs: https://www.terraform.io/docs/configuration/variables.html
################################################################################################################################

##################################################################
# Non-sensitive variables set in dev.tfvars
##################################################################

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

// vpc 

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
}
