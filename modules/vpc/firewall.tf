# Allow Public traffic 
resource "google_compute_firewall" "allow_public_traffic" {
  name     = "${var.name}-allow-public-traffic"
  network  = google_compute_network.vpc.id
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = [google_compute_subnetwork.public_subnet.ip_cidr_range]
  target_tags        = var.piblic_resource_tags
}

# Allow Ephemeral Port Range 
resource "google_compute_firewall" "allow_ephemeral_ports_pub" {
  name     = "allow-ephemeral-ports-pub"
  network  = google_compute_network.vpc.id
  priority = 200

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = [google_compute_subnetwork.public_subnet.ip_cidr_range]
  target_tags        = var.piblic_resource_tags
}

# Allow public subnets to private subnets (backend)
resource "google_compute_firewall" "allow_backend_traffic" {
  name     = "allow-backend-traffic"
  network  = google_compute_network.vpc.id
  priority = 300

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "30000-32767", "22"]
  }

  source_ranges = [google_compute_subnetwork.public_subnet.ip_cidr_range]
  destination_ranges = flatten([
    google_compute_subnetwork.private_subnet.ip_cidr_range,
    [for range in google_compute_subnetwork.private_subnet.secondary_ip_range : range.ip_cidr_range]
  ])
  target_tags = var.private_instance_tags
}

# Allow Ephemeral Port Range TCP
resource "google_compute_firewall" "allow_ephemeral_ports_priv_tcp" {
  name     = "allow-ephemeral-ports-priv"
  network  = google_compute_network.vpc.id
  priority = 400

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  source_ranges = [google_compute_subnetwork.public_subnet.ip_cidr_range]
  destination_ranges = flatten([
    google_compute_subnetwork.private_subnet.ip_cidr_range,
    [for range in google_compute_subnetwork.private_subnet.secondary_ip_range : range.ip_cidr_range]
  ])
  target_tags = var.private_instance_tags
}

resource "google_compute_firewall" "deny_default_rules" {
  name    = "deny-all-default-rules"
  network = google_compute_network.vpc.id

  priority      = 2000 # Lower priority overrides default rules
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }
}
