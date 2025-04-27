provider "google" {
  project = var.project_id
  region  = var.region
}

module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

module "vpc" {
  source                 = "../../modules/vpc"
  environment            = var.environment
  region                 = var.region
  public_ip_cidr_range   = var.public_ip_cidr_range
  private_ip_cidr_range  = var.private_ip_cidr_range
  services_ip_cidr_range = var.services_ip_cidr_range
  pod_ip_cidr_range      = var.pod_ip_cidr_range
  piblic_resource_tags   = ["public-subnet-resources"]
  private_instance_tags  = ["private-instances"]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "infra"
  })

  depends_on = [module.enable_google_service_apis]
}
