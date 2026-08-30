output "id" {
  value       = google_service_account.this.id
  description = "The full ID of the service account"
}

output "name" {
  value       = google_service_account.this.name
  description = "The fully qualified name of the service account"
}

output "email" {
  value       = google_service_account.this.email
  description = "The email address of the service account"
}

output "member" {
  value       = "serviceAccount:${google_service_account.this.email}"
  description = "The service account in the format expected by IAM bindings"
}

output "unique_id" {
  value       = google_service_account.this.unique_id
  description = "The unique id of the service account"
}
