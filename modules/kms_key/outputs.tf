output "name" {
  description = "KMS crypto key name"
  value       = google_kms_crypto_key.kms_key.name
}

output "id" {
  description = "Full ID of the KMS crypto key"
  value       = google_kms_crypto_key.kms_key.id
}
