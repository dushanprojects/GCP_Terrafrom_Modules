resource "google_container_cluster" "gke_cluster" {
  name                    = lower("${var.cluster_name}-gke")
  min_master_version      = coalesce(var.min_master_version, "latest")
  location                = var.region
  network                 = var.vpc_id
  subnetwork              = var.private_subnet_id
  deletion_protection     = false
  enable_multi_networking = true
  enable_shielded_nodes   = true
  datapath_provider       = "ADVANCED_DATAPATH"
  monitoring_service      = "none"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true #(recommended)
  initial_node_count       = 1

  cluster_autoscaling {
    enabled = false
  }

  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    network_policy_config {
      disabled = true
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  dynamic "ip_allocation_policy" {
    for_each = var.custom_vpc_used ? [1] : []
    content {
      cluster_secondary_range_name  = "k8s-pod-range"
      services_secondary_range_name = "k8s-services-range"
    }
  }

  dynamic "service_external_ips_config" {
    for_each = var.custom_vpc_used ? [1] : []
    content {
      enabled = false
    }
  }

  release_channel {
    channel = var.release_channel
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.ip_whitelisting
      content {
        display_name = cidr_blocks.value.display_name
        cidr_block   = cidr_blocks.value.cidr_block
      }
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_recurring_window.start_time
      end_time   = var.maintenance_recurring_window.end_time
      recurrence = var.maintenance_recurring_window.recurrence
    }
  }
}

