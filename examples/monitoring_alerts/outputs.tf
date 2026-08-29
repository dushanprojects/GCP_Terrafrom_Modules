output "notification_channel_ids" {
  value       = module.platform_monitoring.notification_channel_ids
  description = "The full IDs of the notification channels"
}

output "uptime_check_ids" {
  value       = module.platform_monitoring.uptime_check_ids
  description = "A map of the uptime check names and their check ids"
}

output "uptime_alert_policy_names" {
  value       = module.platform_monitoring.uptime_alert_policy_names
  description = "The names of the alert policies created for the uptime checks"
}

output "metric_alert_policy_names" {
  value       = module.platform_monitoring.metric_alert_policy_names
  description = "The names of the alert policies created for the metrics"
}
