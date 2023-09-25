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

// job 

variable "job_name" {
  description = "The name of the job."
  type        = string
}

variable "job_command" {
  description = ""
  type        = string
}

variable "ecr_root_url" {
  description = "The URL for the root of the ECR registry."
  type        = string
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository."
  type        = string
}

// batch env

variable "batch_compute_env_arn" {
  description = "The ARN of the compute environment created for all Batch workloads"
  type        = string
}

variable "batch_role" {
  description = "The ARN of the Batch role that should be applied to the job, by default just pass the cluster role"
  type        = string
}
