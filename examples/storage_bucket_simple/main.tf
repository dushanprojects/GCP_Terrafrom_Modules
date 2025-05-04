provider "google" {
  project = var.project_id
  region  = var.region
}

# Enabeling Service APIs
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "storage-component.googleapis.com"
  ]
}

# Creating a storage bucket
module "gcs" {
  source = "../../modules/storage_bucket"

  name          = "my-example-storage-bucket"
  location      = var.region
  storage_class = "STANDARD"
  common_labels = var.common_labels

  depends_on = [
    module.enable_google_service_apis
  ]
}
