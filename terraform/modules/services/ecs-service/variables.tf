################################################################################################################################
# services/_template/variables.tf
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

// service

variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "service_has_alarm" {
  description = "Should a CloudWatch alarm be provisioned for this service"
  type        = bool
}

variable "fargate_cpu" {
  description = "The amount of CPU to allocate for Fargate"
  type        = number
}

variable "fargate_memory" {
  description = "The amount of memory to allocate for Fargate"
  type        = number
}

variable "desired_count" {
  description = "Number of tasks that should be running"
  type        = number
}

variable "app_port" {
  description = "The port the application will be exposed on"
  type        = number
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

// iam

variable "execution_role_arn" {
  description = "The Amazon Resource Name (ARN) of the execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
}

variable "task_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role that containers in this task can assume."
  type        = string
}
