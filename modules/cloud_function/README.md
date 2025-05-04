# Google Cloud Function Module

This Terraform module provisions a Google Cloud Function using a shared module (../../modules/cloud_function). It relies on inputs such as the function name, region, entry point, source code location, and more. Please refer to the example usage shown below:

## Module Usage

```hcl
module "cloud_function_check_unattached_volumes" {
  source = "../../modules/cloud_function"

  name                     = "check-unattached-volumes"
  region                   = var.region
  runtime                  = "go123"
  entry_point              = "CheckUnattachedVolumes"
  source_archive_file_name = "${path.root}/src/function.zip"
  environment_variables = {
    PROJECT = var.project_id
    REGION  = var.region
  }
  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  #(Optional) If you need to schedule the function via Cloud Scheduler -> Cloud Function
  event_trigger_enabled = true
  cron_schedule         = "0 */1 * * *"
  time_zone             = "Etc/GMT"


  depends_on = [
    data.archive_file.this,
    module.enable_google_service_apis
  ]
}
```

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
| `environment_variables`    | A set of key/value environment variable pairs to assign to the function.    | `map(string)` | Optional |
| `common_labels`            | A map of key-value pairs to tag resources consistently                      | `map(string)` | Optional |


## Outputs

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


## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating GKE clusters and networking resources
- Pre-existing source code to be used for the Cloud Function
- Enabled GCP Service APIs:
  - Cloud Functions API
  - Cloud Build API
  - IAM API
  - Artifact Registry API (if using for deployment)


## Notes

### Enabled Google APIs
This module ensures that all required Google APIs are enabled for deploying and running the Cloud Function:

```hcl
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iamcredentials.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com"
  ]
}
```
These APIs are essential for enabling Cloud Functions, setting up IAM credentials, handling scheduled executions, managing networking, and logging.

---