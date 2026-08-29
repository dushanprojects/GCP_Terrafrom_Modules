output "id" {
  value       = google_artifact_registry_repository.this.id
  description = "The full ID of the Artifact Registry repository"
}

output "name" {
  value       = google_artifact_registry_repository.this.name
  description = "The name of the Artifact Registry repository"
}

output "location" {
  value       = google_artifact_registry_repository.this.location
  description = "The location of the Artifact Registry repository"
}

output "repository_url" {
  value       = "${google_artifact_registry_repository.this.location}-docker.pkg.dev/${google_artifact_registry_repository.this.project}/${google_artifact_registry_repository.this.name}"
  description = "The base URL images are pushed to and pulled from"
}
