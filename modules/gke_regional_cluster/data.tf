#  Look up the available zones in that region and use them
data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
}

data "google_compute_subnetwork" "private_subnet" {
  name    = local.private_subnet_name
  project = var.project_id
  region  = var.region
}
