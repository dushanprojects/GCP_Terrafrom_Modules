resource "google_container_cluster" "gke_cluster" {
  # checkov:skip=CKV_GCP_12:The check looks for the Calico network policy add on. This cluster runs Dataplane V2, which enforces network policy itself and refuses to run alongside the add on
  name                        = lower("${var.cluster_name}-gke")
  min_master_version          = coalesce(var.min_master_version, "latest")
  location                    = var.region
  network                     = var.vpc_id
  subnetwork                  = var.private_subnet_id
  deletion_protection         = false
  enable_multi_networking     = true
  enable_shielded_nodes       = true
  datapath_provider           = "ADVANCED_DATAPATH"
  enable_intranode_visibility = true
  monitoring_service          = var.monitoring_service
  resource_labels             = var.common_labels

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true #(recommended)
  initial_node_count       = 1

  # The default node pool is deleted as soon as the cluster is built, but it
  # exists briefly, so it is hardened the same way as the real node pools
  node_config {
    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  cluster_autoscaling {
    enabled = false
  }

  # Certificate based authentication to the cluster stays off. This is already
  # the default, it is set here so the value is visible rather than implied
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
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

  # Enforces the Binary Authorization policy of the project. The policy Google
  # creates by default admits every image, so this changes nothing until the
  # policy is tightened, and it gives you the hook to tighten it later
  dynamic "binary_authorization" {
    for_each = var.binary_authorization_enabled ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # Maps Kubernetes RBAC to groups in your own directory. Needs a group named
  # gke-security-groups in the domain of the project
  dynamic "authenticator_groups_config" {
    for_each = var.authenticator_security_group != null ? [1] : []
    content {
      security_group = var.authenticator_security_group
    }
  }

  # Lets a Kubernetes service account act as a Google service account, so the
  # pods do not read the credentials of the node from the metadata server
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
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

