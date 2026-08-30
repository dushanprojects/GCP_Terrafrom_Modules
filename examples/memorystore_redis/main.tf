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
    "redis.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

# Creating the VPC the cache is reached from
module "vpc" {
  source = "../../modules/vpc"

  name                  = "us-east-cache-dev"
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
  name          = "us-east-cache-dev-private-services-range"
  network       = module.vpc.vpc_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.private_services_ip_range
  prefix_length = var.private_services_prefix_length

  depends_on = [module.enable_google_service_apis]
}

# Peering the VPC with the Google managed services network, so the cache can be
# reached over private IP
resource "google_service_networking_connection" "private_services_connection" {
  network                 = module.vpc.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_range.name]
  deletion_policy         = "ABANDON"

  depends_on = [module.enable_google_service_apis]
}

# Creating the cache instance for Application 1
module "app1_redis" {
  source = "../../modules/memorystore_redis"

  name           = "dev-app1-cache"
  display_name   = "Development Application 1 cache"
  region         = var.region
  tier           = "STANDARD_HA"
  memory_size_gb = 1
  redis_version  = "REDIS_7_0"

  # Reached privately from the application VPC
  authorized_network = module.vpc.self_link
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  reserved_ip_range  = google_compute_global_address.private_services_range.name

  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"

  persistence_enabled = true
  rdb_snapshot_period = "TWENTY_FOUR_HOURS"

  # Sunday 03:00 UTC
  maintenance_window = {
    day  = "SUNDAY"
    hour = 3
  }

  redis_configs = {
    maxmemory-policy = "allkeys-lru"
  }

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  depends_on = [
    module.enable_google_service_apis,
    google_service_networking_connection.private_services_connection
  ]
}

# Storing the auth string of the cache, so the application reads it from
# Secret Manager instead of from the Terraform outputs
module "app1_redis_auth_string" {
  source = "../../modules/secret_manager"

  secret_id               = "dev-app1-cache-auth-string"
  initial_version_enabled = true
  secret_data             = module.app1_redis.auth_string

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  depends_on = [module.enable_google_service_apis]
}
