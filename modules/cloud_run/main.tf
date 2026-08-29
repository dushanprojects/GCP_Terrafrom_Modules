resource "google_cloud_run_v2_service" "this" {
  name                = var.name
  location            = var.location
  ingress             = var.ingress
  deletion_protection = var.deletion_protection
  labels              = var.common_labels

  template {
    service_account                  = var.service_account_email
    timeout                          = var.request_timeout
    max_instance_request_concurrency = var.max_concurrent_requests
    execution_environment            = var.execution_environment

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
        cpu_idle          = var.cpu_always_allocated ? false : true
        startup_cpu_boost = var.startup_cpu_boost_enabled
      }

      # Plain environment variables
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Environment variables read from Secret Manager
      dynamic "env" {
        for_each = var.secret_environment_variables
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.secret_id
              version = env.value.version
            }
          }
        }
      }

      dynamic "startup_probe" {
        for_each = var.startup_probe_path != null ? [1] : []
        content {
          initial_delay_seconds = var.startup_probe_initial_delay
          period_seconds        = var.startup_probe_period
          failure_threshold     = var.startup_probe_failure_threshold
          http_get {
            path = var.startup_probe_path
            port = var.container_port
          }
        }
      }

      dynamic "liveness_probe" {
        for_each = var.liveness_probe_path != null ? [1] : []
        content {
          period_seconds = var.liveness_probe_period
          http_get {
            path = var.liveness_probe_path
            port = var.container_port
          }
        }
      }
    }

    # Sends outbound traffic of the service through the VPC
    dynamic "vpc_access" {
      for_each = var.vpc_network != null ? [1] : []
      content {
        egress = var.vpc_egress
        network_interfaces {
          network    = var.vpc_network
          subnetwork = var.vpc_subnetwork
        }
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Members allowed to call the service. Use allUsers for a public service
resource "google_cloud_run_v2_service_iam_member" "invokers" {
  for_each = toset(var.invokers)

  name     = google_cloud_run_v2_service.this.name
  location = google_cloud_run_v2_service.this.location
  role     = "roles/run.invoker"
  member   = each.value
}
