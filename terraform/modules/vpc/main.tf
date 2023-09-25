###################################################################################################################################
# vpc/main.tf
#
# This configuration file defines the Virtual Private Cloud (VPC) within which our resources will reside. The VPC is designed 
# to logically isolate our AWS resources, providing security and robust networking functionality. 
# 
# Key features of this configuration include:
# - Defining the CIDR block for the VPC.
# - Specifying Availability Zones for the VPC within the 'us-east-1' region.
# - Setting up both private and public subnets, each with their own CIDR block.
# - Enabling a NAT gateway and a VPN gateway for connecting to resources inside the VPC.
# - Adding tags for easier resource management and cost tracking.
#
###################################################################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Project = var.project_name
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = module.vpc.default_security_group_id
}
