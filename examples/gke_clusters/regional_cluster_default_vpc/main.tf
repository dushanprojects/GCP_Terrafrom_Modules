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

module "regional_cluster_default_vpc" {
  source = "../../../modules/gke_regional_cluster"

  project_id         = var.project_id
  cluster_name       = "regional-example"
  min_master_version = "1.32"
  custom_vpc_used    = false
  vpc_id             = "default"
  private_subnet_id  = "default"
  region             = var.region

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

  depends_on = [module.enable_google_service_apis]
}


