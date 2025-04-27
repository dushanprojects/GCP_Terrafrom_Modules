provider "google" {
  project = var.project_id
  region  = var.region
}

module "enable_google_service_apis" {
  source     = "../../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}


module "vpc" {
  source = "../../../modules/vpc"

  name                   = "stg-us"
  region                 = var.region
  common_labels          = var.common_labels
  public_ip_cidr_range   = local.public_ip_cidr_range
  private_ip_cidr_range  = local.private_ip_cidr_range
  pod_ip_cidr_range      = local.pod_ip_cidr_range
  services_ip_cidr_range = local.services_ip_cidr_range
  master_ipv4_cidr_range = local.master_ipv4_cidr_range
  private_instance_tags  = ["private-instances", "nodepools"]
}

module "regional_private_cluster_custom_vpc" {
  source = "../../../modules/gke_regional_cluster"

  project_id            = var.project_id
  cluster_name          = "regional-myvpc"
  min_master_version    = "1.32"
  custom_vpc_used       = true
  vpc_id                = module.vpc.vpc_id
  private_subnet_id     = module.vpc.private_subnet_id
  master_ipv4_cidr      = local.master_ipv4_cidr_range
  region                = var.region
  private_instance_tags = ["private-instances", "nodepools"]


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

  ip_whitelisting = [
    {
      display_name = "SRE Admin IP CIDR"
      cidr_block   = "80.233.34.189/32"
    },
    {
      display_name = "Temp All allow CIDR" # This is for testing only
      cidr_block   = "0.0.0.0/0"
    }
  ]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "myapp"
  })

  depends_on = [
    module.enable_google_service_apis,
    module.vpc
  ]
}


