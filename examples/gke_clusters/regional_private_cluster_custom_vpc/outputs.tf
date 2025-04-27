output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC with format projects/{{project}}/global/networks/{{name}}"
}

output "vpc_self_link" {
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

output "cluster_name" {
  value       = module.regional_private_cluster_custom_vpc.name
  description = "Get cluster name"
}

output "cluster_id" {
  value       = module.regional_private_cluster_custom_vpc.id
  description = "Cluster ID with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}"
}

output "cluster_self_link" {
  value       = module.regional_private_cluster_custom_vpc.self_link
  description = "The server-defined URL for the resource."
}

output "cluster_endpoint" {
  value       = module.regional_private_cluster_custom_vpc.endpoint
  description = "The IP address of this cluster's Kubernetes master."
}

output "cluster_master_version" {
  value       = module.regional_private_cluster_custom_vpc.master_version
  description = "The current version of the master in the cluster"
}

output "cluster_services_ipv4_cidr" {
  value       = module.regional_private_cluster_custom_vpc.services_ipv4_cidr
  description = "The IP address range of the Kubernetes services in this cluster"
}

output "cluster_ca_certificate" {
  value       = module.regional_private_cluster_custom_vpc.cluster_ca_certificate
  description = "Base64 encoded public certificate that is the root certificate of the cluster."
}

output "availability_zones" {
  value       = module.regional_private_cluster_custom_vpc.availability_zones
  description = "List of zones where nodes will be provisioned."
}
