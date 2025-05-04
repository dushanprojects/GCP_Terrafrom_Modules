output "kms_key_ring_name" {
  description = "The name of the KMS key ring"
  value       = module.gcs_kms_key_ring.name
}

output "kms_key_ring_id" {
  description = "The full ID of the KMS key ring"
  value       = module.gcs_kms_key_ring.id
}

output "kms_key_name" {
  description = "The name of the KMS crypto key"
  value       = module.gcs_kms_key.name
}

output "kms_key_id" {
  description = "The full ID of the KMS crypto key"
  value       = module.gcs_kms_key.id
}

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
