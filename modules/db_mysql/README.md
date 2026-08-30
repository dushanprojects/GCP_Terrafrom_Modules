# Cloud SQL for MySQL Module

This Terraform module provisions a **Google Cloud SQL for MySQL instance** using a shared module (`../../modules/db_mysql`). You can create a public or private IP instance, enable high availability, CMEK disk encryption, automated backups with point in time recovery, Query Insights, custom database flags and a maintenance window, and optionally create the databases and users on the instance. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating a private MySQL instance for Application 1
module "mysql" {
  source = "../../modules/db_mysql"

  name              = "dev-app1-mysql"
  region            = var.region
  database_version  = "MYSQL_8_0"
  tier              = "db-custom-2-7680"
  availability_type = "REGIONAL"
  disk_size         = 20

  # Private IP only - requires a private services access connection on the VPC
  public_ip_enabled = false
  private_network   = module.vpc.network_self_link

  # Backups and point in time recovery
  backup_enabled                 = true
  binary_log_enabled             = true
  backup_start_time              = "23:00"
  retained_backups               = 14
  transaction_log_retention_days = 7

  maintenance_window = {
    day          = 7
    hour         = 3
    update_track = "stable"
  }

  database_flags = [
    {
      name  = "slow_query_log"
      value = "on"
    }
  ]

  databases = [
    { name = "app1" }
  ]

  users = [
    {
      name     = "app1"
      password = var.app1_db_password
    }
  ]

  common_labels = var.common_labels

  depends_on = [
    module.enable_google_service_apis,
  ]
}
```

## Inputs

| Name                                            | Description                                                                                              | Type           | Required |
|-------------------------------------------------|----------------------------------------------------------------------------------------------------------|----------------|----------|
| `name`                                          | The name of the DB instance                                                                              | `string`       | Yes      |
| `region`                                        | The region the instance will sit in                                                                      | `string`       | Yes      |
| `database_version`                              | The MySQL Server version to use (default `MYSQL_8_0`)                                                    | `string`       | Optional |
| `maintenance_version`                           | The current software version on the instance. Leave unset to let Google manage it                        | `string`       | Optional |
| `master_instance_name`                          | The name of the existing instance that will act as the master in the replication setup                   | `string`       | Optional |
| `root_password`                                 | Initial root password. Can be updated                                                                    | `string`       | Optional |
| `encryption_key_name`                           | The full path to the encryption key used for the CMEK disk encryption                                    | `string`       | Optional |
| `deletion_protection`                           | Whether Terraform will be prevented from destroying the instance (default `true`)                        | `bool`         | Optional |
| `api_deletion_protection_enabled`               | Whether the instance is protected against deletion by the Cloud SQL API and Console (default `true`)     | `bool`         | Optional |
| `tier`                                          | The machine type to use, e.g. `db-f1-micro`, `db-custom-2-7680`                                          | `string`       | Optional |
| `edition`                                       | The edition of the instance (`ENTERPRISE`\|`ENTERPRISE_PLUS`)                                            | `string`       | Optional |
| `availability_type`                             | `ZONAL` for single zone or `REGIONAL` for HA                                                             | `string`       | Optional |
| `disk_type`                                     | The type of data disk (`PD_SSD`\|`PD_HDD`)                                                               | `string`       | Optional |
| `disk_size`                                     | The size of data disk in GB (default `10`)                                                               | `number`       | Optional |
| `disk_autoresize_enabled`                       | Whether the data disk grows automatically as storage fills up                                            | `bool`         | Optional |
| `disk_autoresize_limit`                         | The maximum size the data disk can grow to in GB (`0` means no limit)                                    | `number`       | Optional |
| `public_ip_enabled`                             | Whether the instance is assigned a public IPv4 address (default `false`)                                 | `bool`         | Optional |
| `private_network`                               | The self link of the VPC the instance is served from over private IP                                     | `string`       | Optional |
| `allocated_ip_range`                            | The name of the allocated IP range used for the private IP address                                       | `string`       | Optional |
| `private_path_for_google_cloud_services_enabled` | Whether services such as BigQuery can reach the instance over private IP                                 | `bool`         | Optional |
| `ssl_mode`                                      | Enforcement of SSL/TLS on connections (default `ENCRYPTED_ONLY`)                                         | `string`       | Optional |
| `authorized_networks`                           | List of external networks allowed to connect over public IP                                              | `list(object)` | Optional |
| `backup_enabled`                                | Whether automated backups are taken. Must be disabled on read replicas                                   | `bool`         | Optional |
| `binary_log_enabled`                            | Whether binary logging is enabled. Required for point in time recovery and read replicas                 | `bool`         | Optional |
| `backup_start_time`                             | HH:MM format time in UTC the backup window starts                                                        | `string`       | Optional |
| `backup_location`                               | The region the backups are stored in                                                                     | `string`       | Optional |
| `transaction_log_retention_days`                | The number of days transaction logs are retained for point in time recovery                              | `number`       | Optional |
| `retained_backups`                              | The number of automated backups to retain                                                                | `number`       | Optional |
| `maintenance_window`                            | Maintenance day (1 Monday to 7 Sunday), hour in UTC (0 to 23) and update track                           | `object`       | Optional |
| `database_flags`                                | List of MySQL server flags to set on the instance                                                        | `list(object)` | Optional |
| `query_insights_enabled`                        | Whether Query Insights is enabled on the instance                                                        | `bool`         | Optional |
| `query_string_length`                           | The maximum query length stored in bytes (256 to 4500)                                                   | `number`       | Optional |
| `record_application_tags`                       | Whether Query Insights collects application tags from the query                                          | `bool`         | Optional |
| `record_client_address`                         | Whether Query Insights collects the client address of the query                                          | `bool`         | Optional |
| `databases`                                     | List of databases to create on the instance                                                              | `list(object)` | Optional |
| `users`                                         | List of users to create on the instance                                                                  | `list(object)` | Optional |
| `common_labels`                                 | A map of key-value pairs to tag resources consistently                                                   | `map(string)`  | Optional |

## Outputs

| Name                 | Description                                                                        |
|----------------------|------------------------------------------------------------------------------------|
| `id`                 | The ID of the DB instance                                                          |
| `name`               | The name of the DB instance                                                        |
| `self_link`          | The URI of the created resource                                                    |
| `connection_name`    | The connection name used by the Cloud SQL Auth Proxy and connectors                |
| `private_ip_address` | The first private IPv4 address assigned to the instance                            |
| `public_ip_address`  | The first public IPv4 address assigned to the instance                             |
| `server_ca_cert`     | The CA certificate information used to connect to the instance over SSL (sensitive) |
| `database_names`     | The names of the databases created on the instance                                 |

## Notes

- **Private IP** - setting `private_network` requires a private services access connection (`google_compute_global_address` with `purpose = "VPC_PEERING"` plus `google_service_networking_connection`) to already exist on that VPC, and the `servicenetworking.googleapis.com` API to be enabled.
- **CMEK** - when `encryption_key_name` is set, the Cloud SQL service account for the project needs `roles/cloudkms.cryptoKeyEncrypterDecrypter` on the key before the instance is created.
- **Read replicas** - set `master_instance_name` to the master instance name and set `backup_enabled = false`; the master must have `binary_log_enabled = true`.
- **Deletion** - both `deletion_protection` (Terraform) and `api_deletion_protection_enabled` (API and Console) default to `true`. Both must be set to `false` before an instance can be destroyed.
- **Passwords** - `root_password` and the `users` passwords land in Terraform state. Source them from Secret Manager or an equivalent rather than committing them.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/db_mysql`):

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
- Ensure proper IAM permissions for creating Cloud SQL instances, databases and users
- Google Service APIs `sqladmin.googleapis.com`, `servicenetworking.googleapis.com (private IP)` and `cloudkms.googleapis.com (optional)` should be enabled
---
