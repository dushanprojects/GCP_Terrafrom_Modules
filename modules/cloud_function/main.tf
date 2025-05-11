
resource "google_storage_bucket" "artifact" {
  name     = "${var.name}-cloudfunctions-artifact-bucket"
  location = var.region
}

resource "google_storage_bucket_object" "archive" {
  name   = "function.zip"
  bucket = google_storage_bucket.artifact.name
  source = var.source_archive_file_name
}

# Cloud Function
resource "google_cloudfunctions_function" "function" {
  name                         = var.name
  description                  = var.description
  runtime                      = var.runtime
  available_memory_mb          = var.available_memory_mb
  trigger_http                 = true
  https_trigger_security_level = "SECURE_ALWAYS"
  timeout                      = var.timeout
  kms_key_name                 = var.kms_key_name
  entry_point                  = var.entry_point
  labels                       = var.common_labels
  environment_variables        = var.environment_variables
  source_archive_bucket        = google_storage_bucket.artifact.name
  source_archive_object        = google_storage_bucket_object.archive.name
}

# IAM Service Account for invoking the function
resource "google_service_account" "invoker" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name} Cloud Function Invoker Service Account"
}

# IAM entry for a service account to invoke the cloudfunction
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.invoker.email}"
}

# IAM entry for a service account to read the artifactregistry
resource "google_project_iam_binding" "artifact_read_access" {
  project = google_cloudfunctions_function.function.project
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_service_account.invoker.email}"
  ]
}

# Additional Role binding
resource "google_project_iam_binding" "additional_iam_bindings" {
  count = length(var.additional_iam_bindings)

  project = google_cloudfunctions_function.function.project
  role    = var.additional_iam_bindings[count.index]

  members = [
    "serviceAccount:${google_service_account.invoker.email}"
  ]
}

# Cloud Function scheduler job
resource "google_cloud_scheduler_job" "function_cron_job" {
  count       = var.event_trigger_enabled ? 1 : 0
  name        = "${var.name}-cron"
  description = "Scheduled trigger for function ${var.name}"
  schedule    = var.cron_schedule
  time_zone   = var.time_zone

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.function.https_trigger_url

    oidc_token {
      service_account_email = google_service_account.invoker.email
    }
  }
}
