locals {
  node_locations       = data.google_compute_zones.available.names
  private_subnet_parts = split("/", var.private_subnet_id)
  private_subnet_name  = element(local.private_subnet_parts, length(local.private_subnet_parts) - 1)
}
