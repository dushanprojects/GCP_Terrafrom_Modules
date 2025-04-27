
# Allow POD/service traffic within private subnets
resource "google_compute_firewall" "allow_pod_and_svc_traffic" {
  count    = var.custom_vpc_used ? 1 : 0
  name     = "allow-pod-and-svc-traffic"
  network  = var.vpc_id
  priority = 500

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  source_ranges = flatten([
    data.google_compute_subnetwork.private_subnet.ip_cidr_range,
    [for range in data.google_compute_subnetwork.private_subnet.secondary_ip_range : range.ip_cidr_range]
  ])
  destination_ranges = flatten([
    data.google_compute_subnetwork.private_subnet.ip_cidr_range,
    [for range in data.google_compute_subnetwork.private_subnet.secondary_ip_range : range.ip_cidr_range]
  ])
  target_tags = var.private_instance_tags
}

# Allow Cluster masters traffic to private subnets
resource "google_compute_firewall" "allow_masters_traffic" {
  count    = var.custom_vpc_used ? 1 : 0
  name     = "allow-masters-traffic"
  network  = var.vpc_id
  priority = 500

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  source_ranges = [var.master_ipv4_cidr]
  destination_ranges = flatten([
    data.google_compute_subnetwork.private_subnet.ip_cidr_range,
    [for range in data.google_compute_subnetwork.private_subnet.secondary_ip_range : range.ip_cidr_range]
  ])
  target_tags = var.private_instance_tags
}
