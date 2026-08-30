# Where the alerts are sent to
resource "google_monitoring_notification_channel" "channels" {
  for_each = { for channel in var.notification_channels : channel.display_name => channel }

  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
  enabled      = true
}

# Checks that the endpoint answers from several locations around the world
resource "google_monitoring_uptime_check_config" "checks" {
  for_each = { for check in var.uptime_checks : check.display_name => check }

  display_name = each.value.display_name
  timeout      = each.value.timeout
  period       = each.value.period

  http_check {
    path           = each.value.path
    port           = each.value.use_ssl ? 443 : 80
    use_ssl        = each.value.use_ssl
    validate_ssl   = each.value.use_ssl
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = each.value.host
    }
  }
}

# Alerts on the uptime checks created above
resource "google_monitoring_alert_policy" "uptime_check_alerts" {
  for_each = { for check in var.uptime_checks : check.display_name => check }

  display_name = "${each.value.display_name} is failing"
  combiner     = "OR"
  user_labels  = var.common_labels

  conditions {
    display_name = "${each.value.display_name} check failed"

    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.labels.check_id=\"${google_monitoring_uptime_check_config.checks[each.key].uptime_check_id}\""
      comparison      = "COMPARISON_GT"
      threshold_value = each.value.failing_locations
      duration        = "60s"

      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.host"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [for channel in google_monitoring_notification_channel.channels : channel.id]

  documentation {
    content   = "The uptime check ${each.value.display_name} is failing from ${each.value.failing_locations} or more locations. Check the service and the load balancer before you look at the application."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = var.auto_close_duration
  }
}

# Alerts on any metric you pass in, for example error rates or latency
resource "google_monitoring_alert_policy" "metric_alerts" {
  for_each = { for alert in var.metric_alerts : alert.display_name => alert }

  display_name = each.value.display_name
  combiner     = "OR"
  enabled      = each.value.enabled
  user_labels  = var.common_labels

  conditions {
    display_name = each.value.display_name

    condition_threshold {
      filter          = each.value.filter
      comparison      = each.value.comparison
      threshold_value = each.value.threshold_value
      duration        = each.value.duration

      aggregations {
        alignment_period     = each.value.alignment_period
        per_series_aligner   = each.value.per_series_aligner
        cross_series_reducer = each.value.cross_series_reducer
        group_by_fields      = each.value.group_by_fields
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [for channel in google_monitoring_notification_channel.channels : channel.id]

  dynamic "documentation" {
    for_each = each.value.documentation != null ? [1] : []
    content {
      content   = each.value.documentation
      mime_type = "text/markdown"
    }
  }

  alert_strategy {
    auto_close = var.auto_close_duration
  }
}
