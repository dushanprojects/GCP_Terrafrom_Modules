resource "google_kms_crypto_key" "kms_key" {
  name            = "${var.key_name}-kms-crypto-key"
  purpose         = "ENCRYPT_DECRYPT"
  key_ring        = var.kms_ring_id
  rotation_period = var.rotation_period
  labels          = var.common_labels
}

# Additional Role binding
resource "google_kms_crypto_key_iam_member" "additional_bindings" {
  for_each = { for x, binding in var.additional_iam_bindings : "${x}" => binding }

  crypto_key_id = google_kms_crypto_key.kms_key.id
  role          = each.value.role
  member        = each.value.member
}
