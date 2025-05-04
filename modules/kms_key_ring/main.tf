resource "google_kms_key_ring" "kms_ring" {
  name     = "${var.name}-kms-key-ring"
  location = var.location
}
