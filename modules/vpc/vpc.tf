resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name                     = "${var.name}-public-subnet"
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.public_ip_cidr_range
  region                   = var.region
  private_ip_google_access = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${var.name}-private-subnet"
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.private_ip_cidr_range
  region                   = var.region
  private_ip_google_access = true
  purpose                  = "PRIVATE"
  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = var.pod_ip_cidr_range
  }
  secondary_ip_range {
    range_name    = "k8s-services-range"
    ip_cidr_range = var.services_ip_cidr_range
  }
}

resource "google_compute_router" "nat_router" {
  name    = "${var.name}-nat-router"
  network = google_compute_network.vpc.id
  region  = google_compute_subnetwork.private_subnet.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }

}
