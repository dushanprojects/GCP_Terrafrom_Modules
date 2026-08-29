# Memorystore Redis Module

This Terraform module provisions a **Google Memorystore for Redis instance** using a shared module (`../../modules/memorystore_redis`). You can create a single node or a replicated instance, reach it privately from your own VPC, require an auth string and in transit encryption, set a maintenance window, keep RDB snapshots so the data survives a restart, and pass your own Redis configuration settings. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating the cache instance for Application 1
module "app1_redis" {
  source = "../../modules/memorystore_redis"

  name           = "dev-app1-cache"
  region         = var.region
  tier           = "STANDARD_HA"
  memory_size_gb = 1
  redis_version  = "REDIS_7_0"

  # Reached privately from the application VPC
  authorized_network = module.vpc.self_link
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  reserved_ip_range  = google_compute_global_address.private_services_range.name

  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"

  maintenance_window = {
    day  = "SUNDAY"
    hour = 3
  }

  redis_configs = {
    maxmemory-policy = "allkeys-lru"
  }

  common_labels = var.common_labels

  depends_on = [
    module.enable_google_service_apis,
    google_service_networking_connection.private_services_connection
  ]
}
```

## Inputs

| Name                      | Description                                                                              | Type          | Required |
|---------------------------|--------------------------------------------------------------------------------------------|---------------|----------|
| `name`                    | The name of the Redis instance                                                            | `string`      | Yes      |
| `region`                  | The region the instance will sit in                                                       | `string`      | Yes      |
| `display_name`            | The display name of the Redis instance                                                    | `string`      | Optional |
| `tier`                    | The service tier of the instance (BASIC\|STANDARD_HA)                                     | `string`      | Optional |
| `memory_size_gb`          | The memory size of the instance in GB                                                     | `number`      | Optional |
| `redis_version`           | The version of Redis the instance runs                                                    | `string`      | Optional |
| `location_id`             | The zone the primary node sits in                                                         | `string`      | Optional |
| `alternative_location_id` | The zone the replica node sits in                                                         | `string`      | Optional |
| `authorized_network`      | The VPC the instance is reached from                                                      | `string`      | Optional |
| `connect_mode`            | How the instance is reached from the VPC (DIRECT_PEERING\|PRIVATE_SERVICE_ACCESS)         | `string`      | Optional |
| `reserved_ip_range`       | The name of the allocated IP range the instance takes its address from                    | `string`      | Optional |
| `auth_enabled`            | Whether clients have to send an auth string before they can use the instance              | `bool`        | Optional |
| `transit_encryption_mode` | Whether the traffic to the instance is encrypted                                          | `string`      | Optional |
| `maintenance_window`      | Maintenance day such as SUNDAY and hour of day in UTC from 0 to 23                        | `object`      | Optional |
| `persistence_enabled`     | Whether the instance writes RDB snapshots so the data survives a restart                  | `bool`        | Optional |
| `rdb_snapshot_period`     | How often an RDB snapshot is taken                                                        | `string`      | Optional |
| `redis_configs`           | A map of Redis configuration settings, for example maxmemory-policy                       | `map(string)` | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                                    | `map(string)` | Optional |

## Outputs

| Name                  | Description                                                     |
|-----------------------|-----------------------------------------------------------------|
| `id`                  | The full ID of the Redis instance                               |
| `name`                | The name of the Redis instance                                  |
| `host`                | The IP address clients connect to                               |
| `port`                | The port clients connect to                                     |
| `current_location_id` | The zone the primary node currently sits in                     |
| `auth_string`         | The auth string clients send before they can use the instance   |

## Notes

- `PRIVATE_SERVICE_ACCESS` needs a private services access connection on the VPC, the same connection the Cloud SQL private IP instances use. `DIRECT_PEERING` does not need one but gives you less control over the address range.
- Changing `memory_size_gb` on a BASIC tier instance restarts the instance and the data is lost. The STANDARD_HA tier resizes without losing the data.
- The `auth_string` output is sensitive. Read it with `terraform output -raw` and store it in Secret Manager rather than passing it around.
- The `redis_configs` keys are the Redis setting names such as `maxmemory-policy` and `notify-keyspace-events`.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/memorystore_redis`):

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
- Proper IAM permissions for creating Memorystore instances
- Google Service APIs `redis.googleapis.com` and `servicenetworking.googleapis.com (private service access)` should be enabled
---
