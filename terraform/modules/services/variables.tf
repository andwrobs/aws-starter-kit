################################################################################################################################
# services/variables.tf
# 
# These values are passed as input variables to all configured services and their related resources.
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

// cluster

variable "cluster_arn" {
  description = "The Amazon Resource Number (ARN) of the ECS cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

// network

variable "internet_alb_arn" {
  type        = string
  description = "The ARN of the Internet-facing Application Load Balancer (ALB)"
}

variable "internet_alb_http_listener_arn" {
  description = "The ARN of the HTTP listener on the internet-facing ALB"
  type        = string
}

variable "internet_alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener on the internet-facing ALB"
  type        = string
}


variable "internet_alb_sg_id" {
  description = "The ID of the security group for the internet facing Application Load Balancer"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of IDs of private subnets"
  type        = list(string)
}
