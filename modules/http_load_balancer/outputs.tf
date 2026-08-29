output "ip_address" {
  value       = google_compute_global_address.this.address
  description = "The public IP address of the load balancer. Point the DNS records of the domains at this address"
}

output "backend_service_id" {
  value       = google_compute_backend_service.this.id
  description = "The full ID of the backend service"
}

output "backend_service_name" {
  value       = google_compute_backend_service.this.name
  description = "The name of the backend service"
}

output "url_map_id" {
  value       = google_compute_url_map.this.id
  description = "The full ID of the URL map"
}

output "ssl_certificate_id" {
  value       = var.ssl_certificate_id != null ? var.ssl_certificate_id : google_compute_managed_ssl_certificate.this[0].id
  description = "The full ID of the SSL certificate served by the load balancer"
}
