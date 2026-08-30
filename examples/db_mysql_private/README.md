
# Cloud SQL for MySQL with Private IP Example

This example demonstrates how to create a private, highly available Cloud SQL for MySQL instance in Google Cloud Platform using Terraform. This example has a dependancy with the VPC module. It reserves an IP range for Google managed services, peers the VPC with the service producer network (private services access), and then provisions the instance so it is only reachable over private IP. The instance defines the machine tier, regional availability, disk sizing, automated backups with point in time recovery, a maintenance window, MySQL server flags, Query Insights, and the application database and user - a configuration suitable for common production or staging environments.

The application user password is generated with `random_password` rather than committed to the repository. In a real environment, source it from Secret Manager instead.

## Inputs (VPC)

| Name                    | Description                                            | Type          | Required |
|-------------------------|--------------------------------------------------------|---------------|----------|
| `name`                  | The name of the VPC                                    | `string`      | Yes      |
| `region`                | The GCP region where the VPC is created                | `string`      | Yes      |
| `public_ip_cidr_range`  | The CIDR range of the VPC public networks              | `string`      | Yes      |
| `private_ip_cidr_range` | The CIDR range of the VPC private networks             | `string`      | Yes      |
| `common_labels`         | A map of key-value pairs to tag resources consistently | `map(string)` | Yes      |

## Inputs (MySQL Instance)

| Name                             | Description                                                                 | Type           | Required |
|----------------------------------|-----------------------------------------------------------------------------|----------------|----------|
| `name`                           | The name of the DB instance                                                 | `string`       | Yes      |
| `region`                         | The region the instance will sit in                                         | `string`       | Yes      |
| `database_version`               | The MySQL Server version to use                                             | `string`       | Optional |
| `tier`                           | The machine type to use, e.g. `db-f1-micro`, `db-custom-2-7680`             | `string`       | Optional |
| `edition`                        | The edition of the instance (ENTERPRISE\|ENTERPRISE_PLUS)                   | `string`       | Optional |
| `availability_type`              | `ZONAL` for single zone or `REGIONAL` for HA                                | `string`       | Optional |
| `disk_type`                      | The type of data disk (PD_SSD\|PD_HDD)                                      | `string`       | Optional |
| `disk_size`                      | The size of data disk in GB                                                 | `number`       | Optional |
| `public_ip_enabled`              | Whether the instance is assigned a public IPv4 address                      | `bool`         | Optional |
| `private_network`                | The self link of the VPC the instance is served from over private IP        | `string`       | Optional |
| `allocated_ip_range`             | The name of the allocated IP range used for the private IP address          | `string`       | Optional |
| `ssl_mode`                       | Enforcement of SSL/TLS on connections                                       | `string`       | Optional |
| `backup_enabled`                 | Whether automated backups are taken                                         | `bool`         | Optional |
| `binary_log_enabled`             | Whether binary logging is enabled, required for point in time recovery      | `bool`         | Optional |
| `backup_start_time`              | HH:MM format time in UTC the backup window starts                           | `string`       | Optional |
| `retained_backups`               | The number of automated backups to retain                                   | `number`       | Optional |
| `transaction_log_retention_days` | The number of days transaction logs are retained                            | `number`       | Optional |
| `maintenance_window`             | Maintenance day (1 Monday to 7 Sunday), hour in UTC and update track        | `object`       | Optional |
| `database_flags`                 | List of MySQL server flags to set on the instance                           | `list(object)` | Optional |
| `query_insights_enabled`         | Whether Query Insights is enabled on the instance                           | `bool`         | Optional |
| `databases`                      | List of databases to create on the instance                                 | `list(object)` | Optional |
| `users`                          | List of users to create on the instance                                     | `list(object)` | Optional |
| `common_labels`                  | A map of key-value pairs to tag resources consistently                      | `map(string)`  | Optional |

## Outputs

| Name                          | Description                                                             |
|-------------------------------|-------------------------------------------------------------------------|
| `vpc_id`                      | ID of the VPC with format projects/{{project}}/global/networks/{{name}} |
| `private_services_range_name` | The name of the IP range reserved for Google managed services           |
| `mysql_instance_name`         | The name of the DB instance                                             |
| `mysql_connection_name`       | The connection name used by the Cloud SQL Auth Proxy and connectors     |
| `mysql_private_ip_address`    | The first private IPv4 address assigned to the instance                 |
| `mysql_self_link`             | The URI of the created resource                                         |
| `mysql_database_names`        | The names of the databases created on the instance                      |
| `app1_db_user_password`       | The generated password of the app1 database user (sensitive)            |

# Provisioning Instructions

## Prerequisites
Before deploying this example, ensure you have the following configured:

 - Set the `region` and `project_id` variables in the `variables.tf` file to match your Google Cloud environment.
 - Make sure the CIDR ranges in `variables.tf` do not overlap with any existing network in the project. The `private_services_ip_range` is handed to Google managed services and cannot overlap with your subnets.

These values are required to properly target the correct project and region for resource discovery.

## Terraform commands
To deploy this example, run the following commands from within this directory:
- `terraform init` - Initializes the working directory and downloads necessary providers.
- `terraform plan` - Previews the changes Terraform will make to your infrastructure.
- `terraform apply` - Applies the planned infrastructure changes.
- `terraform destroy` - Tears down all resources created by this configuration.

The instance is only reachable over private IP, so connect from a VM in the VPC, or through the Cloud SQL Auth Proxy:
- `cloud-sql-proxy $(terraform output -raw mysql_connection_name) --private-ip`
- `terraform output -raw app1_db_user_password` prints the generated app1 user password.

## Notes
- `deletion_protection` and `api_deletion_protection_enabled` both default to `true` in the module. Set both to `false` before running `terraform destroy`, otherwise the instance will refuse to be deleted.
- The private services access peering is created with `deletion_policy = "ABANDON"` so that `terraform destroy` is not blocked while Google managed services are still attached to the range.
