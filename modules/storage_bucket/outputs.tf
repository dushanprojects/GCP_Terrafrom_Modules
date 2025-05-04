output "url" {
  value       = google_storage_bucket.this.url
  description = "The base URL of the bucket, in the format gs://<bucket-name>"
}

output "name" {
  value       = google_storage_bucket.this.name
  description = "Name of the storage bucket"
}

output "self_link" {
  value       = google_storage_bucket.this.self_link
  description = "The URI of the created resource."
}
