
# Memorystore Redis with Private Access Example

This example demonstrates how to create a private Memorystore for Redis cache in Google Cloud Platform using Terraform. This example has a dependancy with the VPC, memorystore redis and secret manager modules. It reserves an IP range for Google managed services, peers the VPC with the service producer network (private services access), creates a replicated cache instance that requires an auth string and encrypts the traffic in transit, and stores the auth string in Secret Manager so the application reads it from there instead of from the Terraform outputs.

## Inputs (VPC)

| Name                    | Description                                            | Type          | Required |
|-------------------------|--------------------------------------------------------|---------------|----------|
| `name`                  | The name of the VPC                                    | `string`      | Yes      |
| `region`                | The GCP region where the VPC is created                | `string`      | Yes      |
| `public_ip_cidr_range`  | The CIDR range of the VPC public networks              | `string`      | Yes      |
| `private_ip_cidr_range` | The CIDR range of the VPC private networks             | `string`      | Yes      |
| `common_labels`         | A map of key-value pairs to tag resources consistently | `map(string)` | Yes      |

## Inputs (Memorystore Redis)

| Name                      | Description                                                                    | Type          | Required |
|---------------------------|----------------------------------------------------------------------------------|---------------|----------|
| `name`                    | The name of the Redis instance                                                  | `string`      | Yes      |
| `region`                  | The region the instance will sit in                                             | `string`      | Yes      |
| `display_name`            | The display name of the Redis instance                                          | `string`      | Optional |
| `tier`                    | The service tier of the instance (BASIC\|STANDARD_HA)                           | `string`      | Optional |
| `memory_size_gb`          | The memory size of the instance in GB                                           | `number`      | Optional |
| `redis_version`           | The version of Redis the instance runs                                          | `string`      | Optional |
| `authorized_network`      | The VPC the instance is reached from                                            | `string`      | Optional |
| `connect_mode`            | How the instance is reached from the VPC                                        | `string`      | Optional |
| `reserved_ip_range`       | The name of the allocated IP range the instance takes its address from          | `string`      | Optional |
| `auth_enabled`            | Whether clients have to send an auth string before they can use the instance    | `bool`        | Optional |
| `transit_encryption_mode` | Whether the traffic to the instance is encrypted                                | `string`      | Optional |
| `maintenance_window`      | Maintenance day such as SUNDAY and hour of day in UTC from 0 to 23              | `object`      | Optional |
| `persistence_enabled`     | Whether the instance writes RDB snapshots so the data survives a restart        | `bool`        | Optional |
| `redis_configs`           | A map of Redis configuration settings, for example maxmemory-policy             | `map(string)` | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                          | `map(string)` | Optional |

## Inputs (Secret Manager)

| Name                      | Description                                                     | Type          | Required |
|---------------------------|-------------------------------------------------------------------|---------------|----------|
| `secret_id`               | The name of the secret                                           | `string`      | Yes      |
| `initial_version_enabled` | Whether an initial secret version is created from `secret_data`  | `bool`        | Optional |
| `secret_data`             | The initial value of the secret                                  | `string`      | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently           | `map(string)` | Optional |

## Outputs

| Name                          | Description                                                             |
|-------------------------------|-------------------------------------------------------------------------|
| `vpc_id`                      | ID of the VPC with format projects/{{project}}/global/networks/{{name}} |
| `private_services_range_name` | The name of the IP range reserved for Google managed services           |
| `redis_instance_name`         | The name of the Redis instance                                          |
| `redis_host`                  | The IP address clients connect to                                       |
| `redis_port`                  | The port clients connect to                                             |
| `redis_auth_secret_id`        | The name of the secret holding the auth string of the cache             |

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

The cache is only reachable over private IP, so connect from a VM or a workload inside the VPC.

## Notes
- The instance uses the same private services access connection that a Cloud SQL private IP instance uses. When both run in one VPC they share the reserved range, so give the range enough addresses.
- The auth string is written to Secret Manager by this example, which means it is also held in the Terraform state. Grant read access on the state bucket accordingly.
- The example uses the `STANDARD_HA` tier, which keeps a replica in a second zone. The `BASIC` tier is cheaper but loses the data when the node restarts.
