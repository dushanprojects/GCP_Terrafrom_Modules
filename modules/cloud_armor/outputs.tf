output "id" {
  value       = google_compute_security_policy.this.id
  description = "The full ID of the Cloud Armor security policy"
}

output "name" {
  value       = google_compute_security_policy.this.name
  description = "The name of the Cloud Armor security policy"
}

output "self_link" {
  value       = google_compute_security_policy.this.self_link
  description = "The URI of the created resource"
}
