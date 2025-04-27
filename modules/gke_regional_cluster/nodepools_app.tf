#########################################################################################################
####################################### Application nodepools ###########################################
#########################################################################################################
resource "google_container_node_pool" "application_nodepools" {
  count = length(var.application_nodepools)

  name           = lookup(var.application_nodepools[count.index], "name", "nodepool-${count.index + 1}")
  cluster        = google_container_cluster.gke_cluster.name
  version        = google_container_cluster.gke_cluster.min_master_version
  location       = var.region
  node_locations = local.node_locations

  autoscaling {
    total_min_node_count = lookup(var.application_nodepools[count.index], "min_node_count", 1)
    total_max_node_count = lookup(var.application_nodepools[count.index], "max_node_count", 3)
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
      for_each = lookup(var.application_nodepools[count.index], "node_taints", [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
    machine_type = lookup(var.application_nodepools[count.index], "machine_type", "e2-medium")
    disk_size_gb = lookup(var.application_nodepools[count.index], "disk_size_gb", 30)
    disk_type    = lookup(var.application_nodepools[count.index], "disk_type", "pd-ssd")
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    service_account = google_service_account.nodepool.email
    labels          = merge(var.common_labels, { nodepool = lookup(var.application_nodepools[count.index], "name", "nodepool-${count.index + 1}") })
    tags            = ["private-instances", "nodepools"]
  }

  lifecycle {
    ignore_changes = [autoscaling]
  }
}
################################## End of Application nodepools #########################################
