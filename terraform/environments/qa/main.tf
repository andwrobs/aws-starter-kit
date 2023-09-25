################################################################################################################################
# qa/main.tf
#
# Entry point configuration file for our staging environment.
################################################################################################################################

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# AWS provider
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Terraform settings and state bucket
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

terraform {
  backend "s3" {
    bucket = "qa-tf-backend"
    key    = "main"
    region = "us-east-1"
  }
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Modules
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

module "alb" {
  source = "../../modules/alb"

  # input variables
  // project
  environment_name = var.environment_name
  project_name     = var.project_name
  // network 
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ecs" {
  source = "../../modules/ecs"

  # input variables
  // project
  aws_region       = var.aws_region
  environment_name = var.environment_name
  project_name     = var.project_name
}

module "services" {
  source = "../../modules/services"

  # input variables
  // project
  aws_region       = var.aws_region
  project_name     = var.project_name
  environment_name = var.environment_name
  // ecs
  cluster_arn  = module.ecs.cluster_arn
  cluster_name = module.ecs.cluster_name
  // network
  internet_alb_arn                = module.alb.internet_alb_arn
  internet_alb_sg_id              = module.alb.internet_alb_sg_id
  internet_alb_http_listener_arn  = module.alb.internet_alb_http_listener_arn
  internet_alb_https_listener_arn = module.alb.internet_alb_https_listener_arn
  vpc_id                          = module.vpc.vpc_id
  private_subnets                 = module.vpc.private_subnets
}

module "batch" {
  source = "../../modules/batch"

  # input variables
  // project
  aws_region       = var.aws_region
  project_name     = var.project_name
  environment_name = var.environment_name
  // network
  vpc_default_sg  = module.vpc.default_sg_id
  private_subnets = module.vpc.private_subnets
}

module "vpc" {
  source = "../../modules/vpc"

  # input variables
  // project
  aws_region       = var.aws_region
  environment_name = var.environment_name
  project_name     = var.project_name
  // network config from .tfvars
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}
