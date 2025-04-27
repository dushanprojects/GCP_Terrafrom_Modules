output "function_id" {
  value       = google_cloudfunctions_function.function.id
  description = "Cloud Function ID."
}

output "function_name" {
  value       = google_cloudfunctions_function.function.name
  description = "Cloud Function Name."
}

output "id" {
  value       = google_cloudfunctions_function.function.id
  description = "Cloud Function ID."
}

output "https_trigger_url" {
  value       = google_cloudfunctions_function.function.https_trigger_url
  description = "Function trigger URL (HTTP)."
}

output "artifact_bucket_name" {
  value       = google_storage_bucket.artifact.name
  description = "Source code bucket name."
}

output "invoker_service_account_name" {
  value       = google_service_account.invoker.name
  description = "Invoker service account name."
}

output "invoker_service_account_email" {
  value       = google_service_account.invoker.email
  description = "Invoker service account email."
}

output "cloud_scheduler_id" {
  value       = google_cloud_scheduler_job.function_cron_job[0].id
  description = "Cloud Scheduler job ID."
}

output "cloud_scheduler_name" {
  value       = google_cloud_scheduler_job.function_cron_job[0].name
  description = "Cloud Scheduler job name."
}

output "cloud_scheduler_schedule" {
  value       = google_cloud_scheduler_job.function_cron_job[0].schedule
  description = "Cloud Scheduler cron schedule."
}
