
# Custom VPC Example

This example demonstrates how to create a custom Virtual Private Cloud (VPC) network in Google Cloud Platform using Terraform. It includes subnets, firewall rules, and other network components configured to suit common production or staging environments.

## Inputs

| Name                     | Description                                                     | Type          | Required |
|--------------------------|-----------------------------------------------------------------|---------------|----------|
| `name`                   | The name of the VPC                                             | `string`      | Yes      |
| `region`                 | The GCP region where the cluster is created                     | `string`      | Yes      |
| `common_labels`          | A map of key-value pairs to tag resources consistently          | `map(string)` | Yes      |
| `public_ip_cidr_range`   | The CIDR range of the VPC public networks                       | `string`      | Yes      |
| `private_ip_cidr_range`  | The CIDR range of the VPC private networks                      | `string`      | Yes      |
| `piblic_resource_tags`   | Target public resources Tags to be allowed in Firewall rules    | `string`      | Yes      |
| `private_instance_tags`  | Target private VM instance Tags to be allowed in Firewall rules | `string`      | Yes      |
| `pod_ip_cidr_range`      | Cluster's subnetwork range to use for pods                      | `string`      | Optional |
| `services_ip_cidr_range` | Cluster's subnetwork range to use for service                   | `string`      | Optional |
| `master_ipv4_cidr_range` | The IP CIDR range used by the master/control plane nodes        | `string`      | Optional |


## Outputs

| Name                  | Description                            | 
|-----------------------|----------------------------------------|
| `vpc_id`              | The ID of the VPC network              |
| `self_link`           | The URI of the created resource        |
| `network_id`          | The unique identifier for the resource |
| `vpc_id`              | The ID of the VPC network              |
| `public_subnet_id`    | The ID of the public subnet            |
| `public_subnet_name`  | The name of the public subnet          | 
| `private_subnet_id`   | The ID of the private subnet           | 
| `private_subnet_name` | The name of the private subnet         |

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