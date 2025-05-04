provider "google" {
  project = var.project_id
  region  = var.region
}

# Enabeling KMS Service API
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "cloudkms.googleapis.com"
  ]
}

# Creating a common KMS key ring for GCS
module "gcs_kms_key_ring" {
  source = "../../modules/kms_key_ring"

  name          = "gcs-encryption"
  location      = var.region
  common_labels = var.common_labels
  depends_on    = [module.enable_google_service_apis]
}

# Creating a KMS key for Application 1's GCS bucket.
module "gcs_kms_key" {
  source = "../../modules/kms_key"

  key_name      = "dev-app1-gcs"
  kms_ring_id   = module.gcs_kms_key_ring.id
  common_labels = var.common_labels
  additional_iam_bindings = [
    {
      role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
    }
  ]
  depends_on = [module.enable_google_service_apis, module.gcs_kms_key_ring]
}
