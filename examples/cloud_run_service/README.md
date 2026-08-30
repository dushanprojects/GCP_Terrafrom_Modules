
# Cloud Run Service behind a Load Balancer Example

This example demonstrates how to run a container on Cloud Run and publish it safely in Google Cloud Platform using Terraform. This example has a dependancy with the service account, artifact registry, secret manager, cloud run, cloud armor and http load balancer modules. It creates a runtime service account with only the roles the service needs, a container image repository with cleanup policies, an application secret that is read at start up, the Cloud Run service itself, a Cloud Armor security policy, and an external HTTPS load balancer with a Google managed certificate. The Cloud Run service only accepts traffic from the load balancer, so clients cannot skip the security policy.

The API key is generated with `random_password` rather than committed to the repository. In a real environment, the application team creates the value and adds it to the secret outside of Terraform.

## Inputs (Service Account)

| Name            | Description                                                                        | Type           | Required |
|-----------------|--------------------------------------------------------------------------------------|----------------|----------|
| `project_id`    | Google Project ID the service account is created in                                 | `string`       | Yes      |
| `account_id`    | The account id of the service account, used as the first part of the email address  | `string`       | Yes      |
| `display_name`  | The display name of the service account                                             | `string`       | Optional |
| `description`   | A short description of what the service account is used for                         | `string`       | Optional |
| `project_roles` | List of project level roles granted to the service account                          | `list(string)` | Optional |

## Inputs (Artifact Registry)

| Name                      | Description                                                                       | Type           | Required |
|---------------------------|-------------------------------------------------------------------------------------|----------------|----------|
| `repository_id`           | The name of the Artifact Registry repository                                       | `string`       | Yes      |
| `location`                | The location where the repository is created                                       | `string`       | Yes      |
| `format`                  | The format of packages stored in the repository                                    | `string`       | Optional |
| `immutable_tags_enabled`  | Whether image tags are prevented from being overwritten                            | `bool`         | Optional |
| `cleanup_policy_dry_run`  | Whether the cleanup policies only report what they would delete                    | `bool`         | Optional |
| `delete_older_than`       | Deletes images older than this duration in seconds                                 | `string`       | Optional |
| `keep_most_recent_count`  | The number of most recent images kept regardless of the delete policy              | `number`       | Optional |
| `additional_iam_bindings` | Additional IAM bindings to apply to the repository                                 | `list(object)` | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                             | `map(string)`  | Optional |

## Inputs (Secret Manager)

| Name                      | Description                                                                    | Type           | Required |
|---------------------------|----------------------------------------------------------------------------------|----------------|----------|
| `secret_id`               | The name of the secret                                                          | `string`       | Yes      |
| `initial_version_enabled` | Whether an initial secret version is created from `secret_data`                 | `bool`         | Optional |
| `secret_data`             | The initial value of the secret                                                 | `string`       | Optional |
| `accessors`               | List of members allowed to read the secret value                                | `list(string)` | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                          | `map(string)`  | Optional |

## Inputs (Cloud Run)

| Name                           | Description                                                                     | Type           | Required |
|--------------------------------|-----------------------------------------------------------------------------------|----------------|----------|
| `name`                         | The name of the Cloud Run service                                                | `string`       | Yes      |
| `location`                     | The region the service runs in                                                   | `string`       | Yes      |
| `image`                        | The container image the service runs                                             | `string`       | Yes      |
| `service_account_email`        | The email address of the runtime service account                                 | `string`       | Optional |
| `ingress`                      | Which traffic reaches the service                                                | `string`       | Optional |
| `invokers`                     | List of members allowed to call the service                                      | `list(string)` | Optional |
| `cpu_limit`                    | The number of CPUs available to each instance                                    | `string`       | Optional |
| `memory_limit`                 | The memory available to each instance                                            | `string`       | Optional |
| `min_instances`                | The smallest number of instances kept running                                    | `number`       | Optional |
| `max_instances`                | The largest number of instances the service scales out to                        | `number`       | Optional |
| `environment_variables`        | A map of plain environment variables passed to the container                     | `map(string)`  | Optional |
| `secret_environment_variables` | List of environment variables read from Secret Manager                           | `list(object)` | Optional |
| `common_labels`                | A map of key-value pairs to tag resources consistently                           | `map(string)`  | Optional |

## Inputs (Cloud Armor)

| Name                          | Description                                                               | Type           | Required |
|-------------------------------|-----------------------------------------------------------------------------|----------------|----------|
| `name`                        | The name of the Cloud Armor security policy                                | `string`       | Yes      |
| `default_rule_action`         | The action applied when no other rule matches                              | `string`       | Optional |
| `adaptive_protection_enabled` | Whether Adaptive Protection watches for layer 7 attacks                    | `bool`         | Optional |
| `waf_rules`                   | List of preconfigured WAF rules applied to the traffic                     | `list(object)` | Optional |
| `rate_limit_threshold_count`  | The number of requests a single client is allowed to send in the interval  | `number`       | Optional |

## Inputs (HTTP Load Balancer)

| Name                     | Description                                                           | Type           | Required |
|--------------------------|-------------------------------------------------------------------------|----------------|----------|
| `name`                   | The name used as the prefix of every load balancer resource            | `string`       | Yes      |
| `region`                 | The region the Cloud Run service runs in                               | `string`       | Yes      |
| `cloud_run_service_name` | The name of the Cloud Run service the load balancer sends traffic to   | `string`       | Yes      |
| `domains`                | List of domains the Google managed certificate is issued for           | `list(string)` | Optional |
| `security_policy_id`     | The id of the Cloud Armor security policy attached to the backend      | `string`       | Optional |
| `http_redirect_enabled`  | Whether plain HTTP traffic is redirected to HTTPS                      | `bool`         | Optional |

## Outputs

| Name                       | Description                                                       |
|----------------------------|-------------------------------------------------------------------|
| `service_account_email`    | The email address of the runtime service account                  |
| `artifact_registry_url`    | The base URL images are pushed to and pulled from                 |
| `api_key_secret_id`        | The name of the API key secret                                    |
| `cloud_run_service_name`   | The name of the Cloud Run service                                 |
| `cloud_run_uri`            | The direct URL of the Cloud Run service                           |
| `load_balancer_ip_address` | The public IP address of the load balancer                        |
| `security_policy_name`     | The name of the Cloud Armor security policy                       |

# Provisioning Instructions

## Prerequisites
Before deploying this example, ensure you have the following configured:

 - Set the `region` and `project_id` variables in the `variables.tf` file to match your Google Cloud environment.
 - Set the `domains` variable to the domains you own and are able to create DNS records for.

These values are required to properly target the correct project and region for resource discovery.

## Terraform commands
To deploy this example, run the following commands from within this directory:
- `terraform init` - Initializes the working directory and downloads necessary providers.
- `terraform plan` - Previews the changes Terraform will make to your infrastructure.
- `terraform apply` - Applies the planned infrastructure changes.
- `terraform destroy` - Tears down all resources created by this configuration.

## After the first apply

1. Create a DNS A record for every domain in the `domains` variable, pointing at the `load_balancer_ip_address` output. The Google managed certificate is only issued once the DNS records are in place, which usually takes between 15 and 60 minutes.
2. Build and push your own image to the repository shown in the `artifact_registry_url` output.
3. Change the `image` input of the `app1_cloud_run` module to your own image and apply again. The example starts with the Google sample image so that the first apply works before any of your own images exist.

## Notes
- The Cloud Run module sets `deletion_protection` to `true` by default. Set it to `false` before running `terraform destroy`.
- The example gives the runtime service account only the logging, monitoring and tracing roles. Add the roles your application needs, such as `roles/cloudsql.client`, to the `project_roles` list.
- The Cloud Run service uses the `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` ingress setting, so the direct URL in the `cloud_run_uri` output does not serve public traffic. Use the load balancer address instead.
