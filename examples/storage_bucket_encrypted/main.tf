provider "google" {
  project = var.project_id
  region  = var.region
}

# Enabeling Service APIs
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "storage-component.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

# Creating a common KMS key ring for GCS
module "gcs_kms_key_ring" {
  source = "../../modules/kms_key_ring"

  name          = "us-gcs-encryption"
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

# Creating a storage bucket
module "gcs" {
  source = "../../modules/storage_bucket"

  name                     = "dev-app1-resources-bucket"
  location                 = var.region
  force_destroy_enabled    = true
  public_access_prevention = "enforced"
  storage_class            = "STANDARD"
  encryption_kms_key_id    = module.gcs_kms_key.id
  common_labels            = var.common_labels
  versioning_enabled       = true
  log_bucket_name          = "dev-gcs-access-logs-bucket-new"

  lifecycle_rules = [
    {
      action = {
        type           = "Delete"
        matches_prefix = "/temp"
      }
      condition = {
        age = 3
      }
    },
    {
      action = {
        type           = "Delete"
        matches_prefix = "/processed"
      }
      condition = {
        age = 14
      }
    },
    {
      action = {
        type = "AbortIncompleteMultipartUpload"
      }
      condition = {
        age = 1
      }
    }
  ]

  depends_on = [
    module.enable_google_service_apis,
    module.gcs_kms_key
  ]
}
