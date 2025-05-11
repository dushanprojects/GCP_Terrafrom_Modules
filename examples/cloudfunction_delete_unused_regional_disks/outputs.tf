output "function_id" {
  value       = module.cloud_function_delete_unused_regional_disks.function_id
  description = "Cloud Function ID."
}

output "function_name" {
  value       = module.cloud_function_delete_unused_regional_disks.function_name
  description = "Cloud Function Name."
}

output "https_trigger_url" {
  value       = module.cloud_function_delete_unused_regional_disks.https_trigger_url
  description = "Function trigger URL (HTTP)."
}

output "artifact_bucket_name" {
  value       = module.cloud_function_delete_unused_regional_disks.artifact_bucket_name
  description = "Source code bucket name."
}

output "invoker_service_account_name" {
  value       = module.cloud_function_delete_unused_regional_disks.invoker_service_account_name
  description = "Invoker service account name."
}

output "invoker_service_account_email" {
  value       = module.cloud_function_delete_unused_regional_disks.invoker_service_account_email
  description = "Invoker service account email."
}

output "cloud_scheduler_id" {
  value       = module.cloud_function_delete_unused_regional_disks.cloud_scheduler_id
  description = "Cloud Scheduler job ID."
}

output "cloud_scheduler_name" {
  value       = module.cloud_function_delete_unused_regional_disks.cloud_scheduler_name
  description = "Cloud Scheduler job name."
}

output "cloud_scheduler_schedule" {
  value       = module.cloud_function_delete_unused_regional_disks.cloud_scheduler_schedule
  description = "Cloud Scheduler cron schedule."
}
