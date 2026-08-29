# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  project_id = "example-project"
}

run "nothing_is_created_without_inputs" {
  command = plan

  assert {
    condition     = length(google_monitoring_notification_channel.channels) == 0
    error_message = "No notification channel must be created unless one is given"
  }

  assert {
    condition     = length(google_monitoring_uptime_check_config.checks) == 0
    error_message = "No uptime check must be created unless one is given"
  }

  assert {
    condition     = length(google_monitoring_alert_policy.metric_alerts) == 0
    error_message = "No metric alert must be created unless one is given"
  }
}

run "an_uptime_check_brings_its_own_alert" {
  command = plan

  variables {
    notification_channels = [
      {
        display_name = "Platform team email"
        type         = "email"
        labels       = { email_address = "sre@example.com" }
      }
    ]
    uptime_checks = [
      {
        display_name = "Application 1 public endpoint"
        host         = "app1.example.com"
        path         = "/healthz"
      }
    ]
  }

  assert {
    condition     = length(google_monitoring_uptime_check_config.checks) == 1
    error_message = "One uptime check must be created for every entry given"
  }

  assert {
    condition     = length(google_monitoring_alert_policy.uptime_check_alerts) == 1
    error_message = "Every uptime check must come with an alert policy"
  }

  assert {
    condition     = google_monitoring_uptime_check_config.checks["Application 1 public endpoint"].http_check[0].port == 443
    error_message = "An uptime check must use HTTPS by default"
  }

  assert {
    condition     = google_monitoring_uptime_check_config.checks["Application 1 public endpoint"].monitored_resource[0].labels.host == "app1.example.com"
    error_message = "The uptime check must request the host given"
  }
}

run "metric_alerts_use_the_given_thresholds" {
  command = plan

  variables {
    metric_alerts = [
      {
        display_name    = "Application 1 server error rate is high"
        filter          = "metric.type=\"run.googleapis.com/request_count\""
        threshold_value = 5
      }
    ]
  }

  assert {
    condition     = google_monitoring_alert_policy.metric_alerts["Application 1 server error rate is high"].conditions[0].condition_threshold[0].threshold_value == 5
    error_message = "The alert must use the threshold given"
  }

  assert {
    condition     = google_monitoring_alert_policy.metric_alerts["Application 1 server error rate is high"].conditions[0].condition_threshold[0].comparison == "COMPARISON_GT"
    error_message = "The alert must compare above the threshold by default"
  }
}
