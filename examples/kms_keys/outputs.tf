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
