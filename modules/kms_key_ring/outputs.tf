output "name" {
  description = "The name of the KMS key ring"
  value       = google_kms_key_ring.kms_ring.name
}

output "id" {
  description = "The full ID of the KMS key ring"
  value       = google_kms_key_ring.kms_ring.id
}
