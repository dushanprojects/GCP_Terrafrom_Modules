/*
© 2025 Dushan Wijesinghe - Licensed under the MIT License.

You’re welcome to use, modify, and contribute improvements.
Please keep contributions aligned with the original example.
*/

provider "google" {
  project = var.project_id
  region  = var.region
}

module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iamcredentials.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com"
  ]
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.root}/src/check-unattached-volumes"
  output_path = "${path.root}/src/function.zip"
}

module "cloud_function_check_unattached_volumes" {
  source = "../../modules/cloud_function"

  name                     = "check-unattached-volumes"
  region                   = var.region
  runtime                  = "go123"
  entry_point              = "CheckUnattachedVolumes"
  source_archive_file_name = "${path.root}/src/function.zip"
  environment_variables = {
    PROJECT = var.project_id
    REGION  = var.region
  }
  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  #(Optional) If you need to schedule the function via Cloud Scheduler -> Cloud Function
  event_trigger_enabled = true
  cron_schedule         = "0 */1 * * *"
  time_zone             = "Etc/GMT"


  depends_on = [
    data.archive_file.this,
    module.enable_google_service_apis
  ]
}
