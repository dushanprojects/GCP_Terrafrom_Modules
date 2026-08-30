# Monitoring Alerts Module

This Terraform module provisions **Google Cloud Monitoring uptime checks and alert policies** using a shared module (`../../modules/monitoring_alerts`). You can create the notification channels the alerts are sent to, check that your public endpoints answer from several locations around the world, raise an alert when a check starts failing, and raise alerts on any metric such as an error rate, a request latency or a database connection count. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating the uptime checks and the alerts for Application 1
module "app1_monitoring" {
  source = "../../modules/monitoring_alerts"

  project_id = var.project_id

  notification_channels = [
    {
      display_name = "Platform team email"
      type         = "email"
      labels = {
        email_address = "sre@example.com"
      }
    }
  ]

  uptime_checks = [
    {
      display_name      = "Application 1 public endpoint"
      host              = "app1.example.com"
      path              = "/healthz"
      failing_locations = 2
    }
  ]

  metric_alerts = [
    {
      display_name       = "Application 1 server error rate is high"
      filter             = "metric.type=\"run.googleapis.com/request_count\" AND resource.type=\"cloud_run_revision\" AND metric.labels.response_code_class=\"5xx\""
      threshold_value    = 5
      duration           = "300s"
      per_series_aligner = "ALIGN_RATE"
      documentation      = "The service is returning server errors. Check the Cloud Run logs of the latest revision."
    }
  ]

  common_labels = var.common_labels

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                    | Description                                                                                   | Type           | Required |
|-------------------------|-------------------------------------------------------------------------------------------------|----------------|----------|
| `project_id`            | Google Project ID the alerts are created in                                                    | `string`       | Yes      |
| `notification_channels` | List of channels the alerts are sent to, for example an email address or a Slack channel       | `list(object)` | Optional |
| `uptime_checks`         | List of endpoints checked from several locations around the world                              | `list(object)` | Optional |
| `metric_alerts`         | List of alerts raised on a metric, for example an error rate or a request latency              | `list(object)` | Optional |
| `auto_close_duration`   | How long an alert stays open for after the data stops arriving                                 | `string`       | Optional |
| `common_labels`         | A map of key-value pairs to tag resources consistently                                         | `map(string)`  | Optional |

### Uptime check fields

| Name                | Description                                                            | Default |
|---------------------|------------------------------------------------------------------------|---------|
| `display_name`      | The name of the check, also used as the name of the alert policy       |         |
| `host`              | The host name that is checked                                          |         |
| `path`              | The HTTP path that is requested                                        | `/`     |
| `use_ssl`           | Whether the check uses HTTPS on port 443 instead of HTTP on port 80    | `true`  |
| `period`            | How often the check runs                                               | `60s`   |
| `timeout`           | How long the check waits for an answer                                 | `10s`   |
| `failing_locations` | The number of failing locations before the alert is raised             | `2`     |

### Metric alert fields

| Name                   | Description                                                       | Default             |
|------------------------|-------------------------------------------------------------------|---------------------|
| `display_name`         | The name of the alert policy                                      |                     |
| `filter`               | The Cloud Monitoring filter that selects the metric                |                     |
| `threshold_value`      | The value the metric is compared against                          |                     |
| `comparison`           | How the metric is compared to the threshold                       | `COMPARISON_GT`     |
| `duration`             | How long the threshold has to be passed before the alert is raised | `300s`              |
| `alignment_period`     | The period the raw data points are aligned into                   | `300s`              |
| `per_series_aligner`   | How the data points inside one series are aligned                 | `ALIGN_RATE`        |
| `cross_series_reducer` | How several series are combined into one                          | `REDUCE_SUM`        |
| `group_by_fields`      | The labels the series are grouped by                              | `[]`                |
| `documentation`        | The text sent with the alert, telling the responder what to do    | `null`              |
| `enabled`              | Whether the alert policy is active                                | `true`              |

## Outputs

| Name                        | Description                                                    |
|-----------------------------|----------------------------------------------------------------|
| `notification_channel_ids`  | The full IDs of the notification channels                      |
| `uptime_check_ids`          | A map of the uptime check names and their check ids            |
| `uptime_alert_policy_names` | The names of the alert policies created for the uptime checks  |
| `metric_alert_policy_names` | The names of the alert policies created for the metrics        |

## Notes

- Every alert policy in this module is sent to every notification channel in this module. Use a second copy of the module when different alerts have to go to different teams.
- Uptime checks only reach public endpoints. A private service needs a different check type or an alert on its own metrics instead.
- The `filter` of a metric alert is the same filter you get from the Metrics Explorer in the console. Build the query there first, then copy the filter into the module.
- Write the `documentation` field for every alert. It is the first thing the responder reads at three in the morning.
- Email notification channels are created straight away. Slack and PagerDuty channels need the integration to be set up in the console first.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/monitoring_alerts`):

```
terraform init -backend=false
terraform test
```

The `init` is needed even though the provider is mocked, because Terraform reads the provider schema to check the resource arguments. Useful options while working on the module:

```
terraform test -verbose                        # show the plan behind every test case
terraform test -filter=tests/defaults.tftest.hcl   # run a single test file
```

A failing test prints the message written on the assertion, so the output says what the module should have done rather than only which line failed.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating notification channels, uptime checks and alert policies
- Google Service API `monitoring.googleapis.com` should be enabled
---
