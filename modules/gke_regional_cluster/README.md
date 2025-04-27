# GKE Regional Cluster Module

This Terraform module provisions a **Google Kubernetes Engine (GKE) Regional Cluster** using a shared module (`../modules/gke_regional_cluster`). It relies on inputs such as VPC information, environment settings, and region configuration. This module supports both custom VPCs and the default VPC in the case of a shared VPC setup.

## Module Usage

```hcl
module "cluster" {
  source              = "../modules/gke_regional_cluster"

  project_id         = var.project_id
  region             = var.region
  cluster_name       = "regional-example"
  min_master_version = "1.32"
  custom_vpc_used    = false
  vpc_id             = module.vpc.vpc_id # module.vpc.vpc_id | "default"
  private_subnet_id  = module.vpc.private_subnet_id # module.vpc.private_subnet_id | "default"
  

  gke_managed_components_nodepool = {
    min_node_count = 1
    max_node_count = 2
    machine_type   = "e2-medium"
    disk_size_gb   = 50
    disk_type      = "pd-ssd"
    node_taints = [
      {
        key    = "components.gke.io/gke-managed-components"
        value  = ""
        effect = "NO_EXECUTE"
      }
    ]
  }

  application_nodepools = [
    {
      name           = "app1-shared-nodepool"
      min_node_count = 2
      max_node_count = 3
      machine_type   = "e2-medium"
      disk_size_gb   = 50
      disk_type      = "pd-ssd"
      node_taints = [
        {
          key    = "nodepool"
          value  = "app1-shared"
          effect = "NO_EXECUTE"
        }
      ]
    },
    {
      name           = "app2-shared-nodepool"
      min_node_count = 3
      max_node_count = 6
      machine_type   = "e2-medium"
      disk_size_gb   = 50
      disk_type      = "pd-ssd"
      node_taints = [
        {
          key    = "nodepool"
          value  = "app2-shared"
          effect = "NO_EXECUTE"
        }
      ]
    }
  ]
}
```

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

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating GKE clusters and networking resources
- A pre-created custom VPC or shared default VPC with the required subnet(s)


## Notes

- This module assumes that the VPC and subnet already exist and are passed in via outputs from a vpc module. Otherwise, the default VPC and subnet information should be passed instead.
- For production clusters, ensure that private GKE nodes and authorized networks are enabled for better security.
- Workload Identity and logging/monitoring configuration should be handled inside the `gke_cluster` module.
---