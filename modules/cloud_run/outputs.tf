output "id" {
  value       = google_cloud_run_v2_service.this.id
  description = "The full ID of the Cloud Run service"
}

output "name" {
  value       = google_cloud_run_v2_service.this.name
  description = "The name of the Cloud Run service"
}

output "location" {
  value       = google_cloud_run_v2_service.this.location
  description = "The region the service runs in"
}

output "uri" {
  value       = google_cloud_run_v2_service.this.uri
  description = "The URL the service is reached on"
}

output "latest_ready_revision" {
  value       = google_cloud_run_v2_service.this.latest_ready_revision
  description = "The name of the latest revision that is ready to serve traffic"
}
