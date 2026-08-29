provider "google" {
  project = var.project_id
  region  = var.region
}

# Enabeling Service APIs
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com"
  ]
}

# Creating the VPC the database is served from
module "vpc" {
  source = "../../modules/vpc"

  name                  = "us-east-db-dev"
  region                = var.region
  public_ip_cidr_range  = var.public_ip_cidr_range
  private_ip_cidr_range = var.private_ip_cidr_range

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "infra"
  })

  depends_on = [module.enable_google_service_apis]
}

# Reserving an IP range for Google managed services (private services access)
resource "google_compute_global_address" "private_services_range" {
  name          = "us-east-db-dev-private-services-range"
  network       = module.vpc.vpc_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.private_services_ip_range
  prefix_length = var.private_services_prefix_length

  depends_on = [module.enable_google_service_apis]
}

# Peering the VPC with the Google managed services network, so Cloud SQL can be
# reached over private IP
resource "google_service_networking_connection" "private_services_connection" {
  network                 = module.vpc.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_range.name]
  deletion_policy         = "ABANDON"

  depends_on = [module.enable_google_service_apis]
}

# Generating the application database user password.
# In a real environment source this from Secret Manager instead.
resource "random_password" "app1_db_user" {
  length           = 24
  special          = true
  override_special = "!#%*()-_=+[]{}<>:?"
}

# Creating a private, highly available MySQL instance for Application 1
module "mysql" {
  source = "../../modules/db_mysql"

  name              = "dev-app1-mysql"
  region            = var.region
  database_version  = "MYSQL_8_0"
  tier              = "db-custom-2-7680"
  edition           = "ENTERPRISE"
  availability_type = "REGIONAL"
  disk_type         = "PD_SSD"
  disk_size         = 20

  # Private IP only, served from the VPC peered above
  public_ip_enabled  = false
  private_network    = module.vpc.self_link
  allocated_ip_range = google_compute_global_address.private_services_range.name
  ssl_mode           = "ENCRYPTED_ONLY"

  # Automated backups with point in time recovery
  backup_enabled                 = true
  binary_log_enabled             = true
  backup_start_time              = "23:00"
  retained_backups               = 14
  transaction_log_retention_days = 7

  # Sunday 03:00 UTC
  maintenance_window = {
    day          = 7
    hour         = 3
    update_track = "stable"
  }

  database_flags = [
    {
      name  = "slow_query_log"
      value = "on"
    },
    {
      name  = "long_query_time"
      value = "2"
    }
  ]

  query_insights_enabled = true
  record_client_address  = true

  databases = [
    {
      name = "app1"
    }
  ]

  users = [
    {
      name     = "app1"
      password = random_password.app1_db_user.result
    }
  ]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  depends_on = [
    module.enable_google_service_apis,
    google_service_networking_connection.private_services_connection
  ]
}
