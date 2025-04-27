output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC with format projects/{{project}}/global/networks/{{name}}"
}

output "self_link" {
  value       = module.vpc.self_link
  description = "The URI of the created resource."
}

output "network_id" {
  value       = module.vpc.network_id
  description = "The unique identifier for the resource. This identifier is defined by the server."
}

output "public_subnet_id" {
  value       = module.vpc.public_subnet_id
  description = "The ID of the public subnet."
}

output "private_subnet_id" {
  value       = module.vpc.private_subnet_id
  description = "The ID of the private subnet."
}

output "private_subnet_name" {
  value       = module.vpc.private_subnet_name
  description = "The name of the private subnet."
}

output "public_subnet_name" {
  value       = module.vpc.public_subnet_name
  description = "The name of the public subnet."
}
