resource "google_container_node_pool" "gke_managed_components" {
  name           = "gke-managed-components-nodepool"
  cluster        = google_container_cluster.gke_cluster.name
  version        = google_container_cluster.gke_cluster.min_master_version
  location       = var.region
  node_locations = local.node_locations

  autoscaling {
    total_min_node_count = try(var.gke_managed_components_nodepool.min_node_count, 1)
    total_max_node_count = try(var.gke_managed_components_nodepool.max_node_count, 3)
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    strategy = "BLUE_GREEN"
    blue_green_settings {
      node_pool_soak_duration = "900s"

      standard_rollout_policy {
        batch_percentage    = 0.30
        batch_soak_duration = "300s"
      }
    }
  }

  node_config {
    dynamic "taint" {
      for_each = try(var.gke_managed_components_nodepool.node_taints, [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    machine_type = try(var.gke_managed_components_nodepool.machine_type, "e2-small")
    disk_size_gb = try(var.gke_managed_components_nodepool.disk_size_gb, 30)
    disk_type    = try(var.gke_managed_components_nodepool.disk_type, "pd-ssd")
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    service_account = google_service_account.nodepool.email
    labels          = merge(var.common_labels, { nodepool = "gke-managed-components" })
    tags            = ["private-instances", "nodepools"]
  }

  lifecycle {
    ignore_changes = [autoscaling]
  }
}
