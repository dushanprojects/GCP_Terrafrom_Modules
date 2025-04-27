output "name" {
  value       = module.regional_cluster_default_vpc.name
  description = "Get cluster name"
}

output "id" {
  value       = module.regional_cluster_default_vpc.id
  description = "Cluster ID with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}"
}

output "self_link" {
  value       = module.regional_cluster_default_vpc.self_link
  description = "The server-defined URL for the resource."
}

output "endpoint" {
  value       = module.regional_cluster_default_vpc.endpoint
  description = "The IP address of this cluster's Kubernetes master."
}

output "master_version" {
  value       = module.regional_cluster_default_vpc.master_version
  description = "The current version of the master in the cluster"
}

output "services_ipv4_cidr" {
  value       = module.regional_cluster_default_vpc.services_ipv4_cidr
  description = "The IP address range of the Kubernetes services in this cluster"
}

output "cluster_ca_certificate" {
  value       = module.regional_cluster_default_vpc.cluster_ca_certificate
  description = "Base64 encoded public certificate that is the root certificate of the cluster."
}

output "availability_zones" {
  value       = module.regional_cluster_default_vpc.availability_zones
  description = "List of zones where nodes will be provisioned."
}
