
# Google Cloud Function Example - Check unattached volumes

This Google Cloud Function example identifies and lists unattached (orphaned) persistent disks in your GCP project. It can be used to monitor unused resources and optimize cloud costs by flagging disks that are no longer in use.

## Inputs

| Name                       | Description                                                                 | Type          | Required |
|----------------------------|-----------------------------------------------------------------------------|---------------|----------|
| `name`                     | A user-defined name of the function. Function names must be unique globally | `string`      | Yes      |
| `description`              | Description of the cloud function.                                          | `string`      | Optional |
| `runtime`                  | The runtime in which the function is going to run                           | `string`      | Yes      |
| `source_archive_file_name` | The source archive object (file) the function is going use (source code)    | `string`      | Yes      |
| `available_memory_mb`      | Memory (in MB) allocation for the function                                  | `string`      | Yes      |
| `timeout`                  | Timeout (in seconds) for the function. Default value is 60 seconds          | `number`      | Yes      |
| `kms_key_name`             | The KMS Key name used to encrypt/decrypt function resources - Optional      | `string`      | Optional |
| `entry_point`              | Name of the function that will be executed when Function is triggered       | `string`      | Yes      |
| `event_trigger_enabled`    | Cluster's subnetwork range to use for service                               | `bool`        | Optional |
| `cron_schedule`            | Cron expression used in the function - Optional                             | `string`      | Optional |
| `time_zone`                | Time zone for the cron schedule (e.g. UTC)                                  | `string`      | Optional |
| `environment_variables`    | A set of key/value environment variable pairs to assign to the function.    | `map(string)` | Yes      |
| `common_labels`            | A map of key-value pairs to tag resources consistently                      | `map(string)` | Optional |



## Outputs

| Name                           | Description                      |
|--------------------------------|----------------------------------|
| `function_id`                  | Cloud Function ID                |
| `function_name`                | Cloud Function Name              |
| `https_trigger_url`            | Function trigger URL (HTTP)      |
| `artifact_bucket_name`         | Source code bucket name          |
| `invoker_service_account_name` | Invoker service account name     |
| `invoker_service_account_email`| Invoker service account email    |
| `cloud_scheduler_id`           | Cloud Scheduler job ID           |
| `cloud_scheduler_name`         | Cloud Scheduler job name         |
| `cloud_scheduler_schedule`     | Cloud Scheduler cron schedule    |


# Provisioning Instructions

## Prerequisites

Before deploying this Cloud Function, ensure you have the following configured:

 - Set the `region` and `project_id` variables in the `variables.tf` file to match your Google Cloud environment.

These values are required to properly target the correct project and region for resource discovery.

## Terraform commands

To deploy this example, run the following commands from within this directory:
- `terraform init` – Initializes the working directory and downloads necessary providers.
- `terraform plan` – Previews the changes Terraform will make to your infrastructure.
- `terraform apply` – Applies the planned infrastructure changes.
- `terraform destroy` – Tears down all resources created by this configuration.