# Custom PVC Module

This Terraform module provisions a **Google Custom Vitrual Private Cloud** using a shared module (`../../modules/vpc_custom`). It relies on inputs such as VPC network CIDR information, environment settings, and region configuration. Please refer to the example module usage shown below:

## Module Usage

```hcl
module "vpc" {
  source                 = "../../modules/vpc_custom"
  name                   = "stg-us"
  region                 = var.region
  public_ip_cidr_range   = var.public_ip_cidr_range
  private_ip_cidr_range  = var.private_ip_cidr_range
  services_ip_cidr_range = var.services_ip_cidr_range
  pod_ip_cidr_range      = var.pod_ip_cidr_range
  piblic_resource_tags   = ["public-subnet-resources"]
  private_instance_tags  = ["private-instances"]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })
}
```

## Inputs

| Name                     | Description                                                       | Type          | Required |
|--------------------------|-------------------------------------------------------------------|---------------|----------|
| `name`                   | The name of the VPC                                               | `string`      | Yes      |
| `region`                 | The GCP region where the cluster is created                       | `string`      | Yes      |
| `common_labels`          | A map of key-value pairs to tag resources consistently            | `map(string)` | Yes      |
| `public_ip_cidr_range`   | The CIDR range of the VPC public networks                         | `string`      | Yes      |
| `private_ip_cidr_range`  | The CIDR range of the VPC private networks                        | `string`      | Yes      |
| `piblic_resource_tags`   | Target public resources Tags to be allowed in Firewall rules      | `string`      | Yes      |
| `private_instance_tags`  | Target private VM instance Tags to be allowed in Firewall rules   | `string`      | Yes      |
| `pod_ip_cidr_range`      | Cluster's subnetwork range to use for pods                        | `string`      | Optional |
| `services_ip_cidr_range` | Cluster's subnetwork range to use for service                     | `string`      | Optional |
| `master_ipv4_cidr_range` | The IP CIDR range used by the master/control plane nodes          | `string`      | Optional |
| `public_allowed_tcp_ports` | The TCP ports the public subnet accepts from the internet, defaults to 443 only | `list(string)` | Optional |
| `backend_allowed_tcp_ports` | The TCP ports the private subnet accepts from the public subnet | `list(string)` | Optional |
| `flow_logs_enabled`      | Whether flow logs are collected for both subnets, on by default    | `bool`        | Optional |
| `flow_logs_aggregation_interval` | How often the flow logs are aggregated                     | `string`      | Optional |
| `flow_logs_sampling_rate` | The share of the traffic written to the flow logs, from 0 to 1    | `number`      | Optional |


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


## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/vpc`):

```
terraform init -backend=false
terraform test
```

The `init` is needed even though the provider is mocked, because Terraform reads the provider schema to check the resource arguments. Useful options while working on the module:

```
terraform test -verbose                        # show the plan behind every test case
terraform test -filter=tests/subnets.tftest.hcl   # run a single test file
```

A failing test prints the message written on the assertion, so the output says what the module should have done rather than only which line failed.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating GKE clusters and networking resources
- A pre-created VPC with the required subnet(s)


## Notes

- This module assumes that the VPC and subnet already exist and are passed in via outputs from a `vpc` module.
- For production clusters, ensure that private GKE nodes and authorized networks are enabled for better security.
- Workload Identity and logging/monitoring configuration should be handled inside the `gke_cluster` module.
---
