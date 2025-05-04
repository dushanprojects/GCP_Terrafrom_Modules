
# Google Kubernetes Cluster (GKE) - Custom VPC Example

This example demonstrates how to deploy a Google Kubernetes Engine (GKE) cluster with a custom VPC. The setup leverages a custom VPC network, making it ideal for projects that require a custom VPC configuration, rather than using the default VPC.

## Inputs


| Name                              | Description                                                       | Type           | Required |
|-----------------------------------|-------------------------------------------------------------------|----------------|----------|
| `project_id`                      | The ID of the GCP project where resources will be created.        | `string`       | Yes      |
| `cluster_name`                    | The name of the Kubernetes cluster.                               | `string`       | Yes      |
| `min_master_version`              | The minimum version of the master                                 | `string`       | Optional |
| `region`                          | The GCP region where resources will be provisioned.               | `string`       | Yes      |
| `private_subnet_id`               | The ID of the private subnet used for internal communication.     | `string`       | Yes      |
| `vpc_id`                          | The ID of the custom VPC where the cluster will be deployed.      | `string`       | Yes      |
| `custom_vpc_used`                 | Indicates if a custom VPC is used; affects pod and service naming | `bool`         | Optional |
| `common_labels`                   | A map of common labels to apply to all resources.                 | `map(any)`     | Optional |
| `private_instance_tags`           | A list of tags used to allow private instances in firewall rules  | `list(string)` | Optional |
| `ip_whitelisting`                 | A list of authorized CIDR blocks for network access control.      | `list(object)` | Optional |
| `master_ipv4_cidr`                | The IP CIDR range used by the master/control plane nodes          | `string`       | Optional |
| `maintenance_recurring_window`    | The maintenance recurring window to use for the cluster           | `list(object)` | Optional |
| `gke_managed_components_nodepool` | GKE managed components nodepool spesifications                    | `single object`| Yes      |
| `application_nodepools`           | Application nodepools spesifications                              | `list(any)`    | Optional |


## Outputs

| Name                     | Description                                                                               | 
|--------------------------|-------------------------------------------------------------------------------------------|
| `name`                   | Name of the GKE Cluster                                                                   | 
| `id`                     | Cluster ID with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}          | 
| `self_link`              | The server-defined URL for the resource                                                   | 
| `endpoint`               | The IP address of this cluster's Kubernetes master                                        | 
| `client_certificate`     | Base64 encoded public certificate used by clients to authenticate to the cluster endpoint | 
| `cluster_ca_certificate` | Base64 encoded public certificate that is the root certificate of the cluster             | 
| `master_version`         | The current version of the master in the cluster                                          |
| `services_ipv4_cidr`     | The IP address range of the Kubernetes services in this cluster                           |


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