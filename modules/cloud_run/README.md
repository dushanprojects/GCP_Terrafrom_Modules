# Cloud Run Module

This Terraform module provisions a **Google Cloud Run service** using a shared module (`../../modules/cloud_run`). You can run a container image with its own runtime service account, set the CPU and memory limits, control the scaling and the request concurrency, pass plain and Secret Manager environment variables, send outbound traffic through a VPC, add startup and liveness checks, and control who is allowed to call the service. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating the Application 1 Cloud Run service
module "app1_cloud_run" {
  source = "../../modules/cloud_run"

  name                  = "dev-app1"
  location              = var.region
  image                 = "${module.app1_artifact_registry.repository_url}/app1:v1.0.0"
  service_account_email = module.app1_service_account.email

  # Only the load balancer is allowed to reach the service
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  invokers = ["allUsers"]

  cpu_limit               = "1"
  memory_limit            = "512Mi"
  min_instances           = 1
  max_instances           = 10
  max_concurrent_requests = 80

  environment_variables = {
    APP_ENVIRONMENT = "development"
  }

  secret_environment_variables = [
    {
      name      = "DB_PASSWORD"
      secret_id = module.app1_db_password.secret_id
    }
  ]

  startup_probe_path  = "/healthz"
  liveness_probe_path = "/healthz"

  common_labels = var.common_labels

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                              | Description                                                                                 | Type           | Required |
|-----------------------------------|-----------------------------------------------------------------------------------------------|----------------|----------|
| `name`                            | The name of the Cloud Run service                                                            | `string`       | Yes      |
| `location`                        | The region the service runs in                                                               | `string`       | Yes      |
| `image`                           | The container image the service runs                                                         | `string`       | Yes      |
| `service_account_email`           | The email address of the runtime service account                                             | `string`       | Optional |
| `ingress`                         | Which traffic reaches the service                                                            | `string`       | Optional |
| `container_port`                  | The port the container listens on (default `8080`)                                           | `number`       | Optional |
| `cpu_limit`                       | The number of CPUs available to each instance                                                | `string`       | Optional |
| `memory_limit`                    | The memory available to each instance                                                        | `string`       | Optional |
| `cpu_always_allocated`            | Whether the CPU stays allocated between requests                                             | `bool`         | Optional |
| `startup_cpu_boost_enabled`       | Whether extra CPU is given to an instance while it starts up                                 | `bool`         | Optional |
| `min_instances`                   | The smallest number of instances kept running                                                | `number`       | Optional |
| `max_instances`                   | The largest number of instances the service scales out to                                    | `number`       | Optional |
| `max_concurrent_requests`         | The number of requests each instance handles at the same time                                | `number`       | Optional |
| `request_timeout`                 | The time a request is allowed to take before it is stopped                                   | `string`       | Optional |
| `execution_environment`           | The runtime environment of the service                                                       | `string`       | Optional |
| `environment_variables`           | A map of plain environment variables passed to the container                                 | `map(string)`  | Optional |
| `secret_environment_variables`    | List of environment variables read from Secret Manager                                       | `list(object)` | Optional |
| `vpc_network`                     | The VPC outbound traffic of the service is sent through                                      | `string`       | Optional |
| `vpc_subnetwork`                  | The subnet used for the outbound traffic of the service                                      | `string`       | Optional |
| `vpc_egress`                      | Which outbound traffic is sent through the VPC                                               | `string`       | Optional |
| `startup_probe_path`              | The HTTP path checked while the container starts up                                          | `string`       | Optional |
| `startup_probe_initial_delay`     | The time in seconds before the first startup check is made                                   | `number`       | Optional |
| `startup_probe_period`            | The time in seconds between startup checks                                                   | `number`       | Optional |
| `startup_probe_failure_threshold` | The number of failed startup checks before the instance is restarted                         | `number`       | Optional |
| `liveness_probe_path`             | The HTTP path checked while the container is running                                         | `string`       | Optional |
| `liveness_probe_period`           | The time in seconds between liveness checks                                                  | `number`       | Optional |
| `invokers`                        | List of members allowed to call the service. Use allUsers for a public service               | `list(string)` | Optional |
| `deletion_protection`             | Whether Terraform will be prevented from destroying the service (default `true`)             | `bool`         | Optional |
| `common_labels`                   | A map of key-value pairs to tag resources consistently                                       | `map(string)`  | Optional |

## Outputs

| Name                    | Description                                                       |
|-------------------------|-------------------------------------------------------------------|
| `id`                    | The full ID of the Cloud Run service                              |
| `name`                  | The name of the Cloud Run service                                 |
| `location`              | The region the service runs in                                    |
| `uri`                   | The URL the service is reached on                                 |
| `latest_ready_revision` | The name of the latest revision that is ready to serve traffic    |

## Notes

- The image is managed by Terraform. When a deployment pipeline pushes a new image, pass the new tag through the `image` input, otherwise the next apply puts the previous image back.
- `ingress` defaults to `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` so the service is only reachable through the load balancer. Set it to `INGRESS_TRAFFIC_ALL` when the service is called directly on its own URL.
- A public service needs `allUsers` in `invokers`. Without it the load balancer receives a 403 response from the service.
- The runtime service account needs `roles/secretmanager.secretAccessor` on every secret listed in `secret_environment_variables`.
- `deletion_protection` defaults to `true`. Set it to `false` before running `terraform destroy`.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/cloud_run`):

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
- Proper IAM permissions for creating Cloud Run services and IAM role bindings
- Google Service API `run.googleapis.com` should be enabled
---
