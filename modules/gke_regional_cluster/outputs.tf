output "name" {
  value       = google_container_cluster.gke_cluster.name
  description = "Name of the GKE Cluster"
}

output "id" {
  value       = google_container_cluster.gke_cluster.id
  description = "Cluster ID with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}"
}

output "self_link" {
  value       = google_container_cluster.gke_cluster.self_link
  description = "The server-defined URL for the resource."
}

output "endpoint" {
  value       = google_container_cluster.gke_cluster.endpoint
  description = "The IP address of this cluster's Kubernetes master."
}


output "client_certificate" {
  value       = google_container_cluster.gke_cluster.master_auth.0.client_certificate
  description = "Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
}


output "cluster_ca_certificate" {
  value       = google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
  description = "Base64 encoded public certificate that is the root certificate of the cluster."
}

output "master_version" {
  value       = google_container_cluster.gke_cluster.master_version
  description = "The current version of the master in the cluster"
}

output "services_ipv4_cidr" {
  value       = google_container_cluster.gke_cluster.services_ipv4_cidr
  description = "The IP address range of the Kubernetes services in this cluster"
}

output "availability_zones" {
  value       = data.google_compute_zones.available.names
  description = "List of zones where nodes will be provisioned."
}
