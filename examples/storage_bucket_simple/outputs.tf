output "bucket_url" {
  value       = module.gcs.url
  description = "The base URL of the bucket, in the format gs://<bucket-name>"
}

output "bucket_name" {
  value       = module.gcs.name
  description = "Name of the storage bucket"
}

output "bucket_self_link" {
  value       = module.gcs.self_link
  description = "The URI of the created resource."
}
