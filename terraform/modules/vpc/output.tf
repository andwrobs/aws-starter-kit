###################################################################################################################################
# vpc/outputs.tf
###################################################################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "nat_gateways" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "vpn_gateway" {
  description = "The ID of VPN Gateway"
  value       = module.vpc.vgw_id
}

output "default_sg_id" {
  description = "The default security group created for the VPC"
  value       = module.vpc.default_security_group_id
}
