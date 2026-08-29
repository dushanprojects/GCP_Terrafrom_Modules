
# Monitoring Uptime Checks and Alerts Example

This example demonstrates how to watch a platform with Cloud Monitoring in Google Cloud Platform using Terraform. This example has a dependancy with the monitoring alerts module. It creates an email notification channel for the platform team, an uptime check that requests a public endpoint from several locations around the world, and a set of alert policies covering the Cloud Run error rate, the Cloud Run request latency, and the CPU and disk usage of a Cloud SQL instance. Every alert carries a short documentation text telling the responder what to look at first.

## Inputs (Monitoring Alerts)

| Name                    | Description                                                                              | Type           | Required |
|-------------------------|--------------------------------------------------------------------------------------------|----------------|----------|
| `project_id`            | Google Project ID the alerts are created in                                               | `string`       | Yes      |
| `notification_channels` | List of channels the alerts are sent to, for example an email address or a Slack channel  | `list(object)` | Optional |
| `uptime_checks`         | List of endpoints checked from several locations around the world                         | `list(object)` | Optional |
| `metric_alerts`         | List of alerts raised on a metric, for example an error rate or a request latency         | `list(object)` | Optional |
| `auto_close_duration`   | How long an alert stays open for after the data stops arriving                            | `string`       | Optional |
| `common_labels`         | A map of key-value pairs to tag resources consistently                                    | `map(string)`  | Optional |

## Inputs (Example)

| Name                  | Description                                            | Type          | Required |
|-----------------------|--------------------------------------------------------|---------------|----------|
| `project_id`          | Google Project ID                                      | `string`      | Yes      |
| `region`              | The GCP region where resources will be provisioned     | `string`      | Yes      |
| `alert_email_address` | The email address the alerts are sent to               | `string`      | Yes      |
| `monitored_host`      | The public host name the uptime check requests         | `string`      | Yes      |
| `common_labels`       | A map of key-value pairs to tag resources consistently | `map(string)` | Optional |

## Outputs

| Name                        | Description                                                   |
|-----------------------------|---------------------------------------------------------------|
| `notification_channel_ids`  | The full IDs of the notification channels                     |
| `uptime_check_ids`          | A map of the uptime check names and their check ids           |
| `uptime_alert_policy_names` | The names of the alert policies created for the uptime checks |
| `metric_alert_policy_names` | The names of the alert policies created for the metrics       |

# Provisioning Instructions

## Prerequisites
Before deploying this example, ensure you have the following configured:

 - Set the `region` and `project_id` variables in the `variables.tf` file to match your Google Cloud environment.
 - Set the `alert_email_address` variable to the mailbox the platform team reads.
 - Set the `monitored_host` variable to a public host name that answers HTTPS requests.

These values are required to properly target the correct project and region for resource discovery.

## Terraform commands
To deploy this example, run the following commands from within this directory:
- `terraform init` - Initializes the working directory and downloads necessary providers.
- `terraform plan` - Previews the changes Terraform will make to your infrastructure.
- `terraform apply` - Applies the planned infrastructure changes.
- `terraform destroy` - Tears down all resources created by this configuration.

## Notes
- The email address receives a confirmation mail from Google. The channel only delivers alerts after the address has been confirmed.
- The alerts in this example use the Cloud Run and Cloud SQL metrics. They stay quiet until those services exist in the project and start reporting data.
- The metric filters are the same filters the Metrics Explorer in the console produces. Build a query there first, then copy the filter into the `metric_alerts` list.
- The thresholds in this example are starting points. Review them against the normal behaviour of your own services, otherwise the team learns to ignore the alerts.
