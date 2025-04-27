output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "ID of the VPC with format projects/{{project}}/global/networks/{{name}}"
}

output "self_link" {
  value       = google_compute_network.vpc.self_link
  description = "The URI of the created resource."
}

output "network_id" {
  value       = google_compute_network.vpc.network_id
  description = "The unique identifier for the resource. This identifier is defined by the server."
}

output "public_subnet_id" {
  value       = google_compute_subnetwork.public_subnet.id
  description = "The ID of the public subnet."
}

output "private_subnet_id" {
  value       = google_compute_subnetwork.private_subnet.id
  description = "The ID of the private subnet."
}

output "private_subnet_name" {
  value       = google_compute_subnetwork.private_subnet.name
  description = "The name of the private subnet."
}

output "public_subnet_name" {
  value       = google_compute_subnetwork.public_subnet.name
  description = "The name of the public subnet."
}
