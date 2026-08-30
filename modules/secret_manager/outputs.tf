output "id" {
  value       = google_secret_manager_secret.this.id
  description = "The full ID of the secret with format projects/{{project}}/secrets/{{secret_id}}"
}

output "secret_id" {
  value       = google_secret_manager_secret.this.secret_id
  description = "The name of the secret"
}

output "name" {
  value       = google_secret_manager_secret.this.name
  description = "The fully qualified name of the secret"
}

output "version_id" {
  value       = try(google_secret_manager_secret_version.initial[0].id, null)
  description = "The full ID of the initial secret version, or null when no initial value was set"
}
