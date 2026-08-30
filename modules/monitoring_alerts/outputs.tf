output "notification_channel_ids" {
  value       = [for channel in google_monitoring_notification_channel.channels : channel.id]
  description = "The full IDs of the notification channels"
}

output "uptime_check_ids" {
  value       = { for name, check in google_monitoring_uptime_check_config.checks : name => check.uptime_check_id }
  description = "A map of the uptime check names and their check ids"
}

output "uptime_alert_policy_names" {
  value       = [for policy in google_monitoring_alert_policy.uptime_check_alerts : policy.name]
  description = "The names of the alert policies created for the uptime checks"
}

output "metric_alert_policy_names" {
  value       = [for policy in google_monitoring_alert_policy.metric_alerts : policy.name]
  description = "The names of the alert policies created for the metrics"
}
