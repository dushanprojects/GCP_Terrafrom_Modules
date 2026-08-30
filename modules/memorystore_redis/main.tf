resource "google_redis_instance" "this" {
  name           = var.name
  display_name   = var.display_name
  region         = var.region
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  redis_version  = var.redis_version

  location_id             = var.location_id
  alternative_location_id = var.alternative_location_id

  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  reserved_ip_range       = var.reserved_ip_range
  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode

  redis_configs = var.redis_configs
  labels        = var.common_labels

  dynamic "maintenance_policy" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      weekly_maintenance_window {
        day = maintenance_policy.value.day
        start_time {
          hours   = maintenance_policy.value.hour
          minutes = 0
          seconds = 0
          nanos   = 0
        }
      }
    }
  }

  dynamic "persistence_config" {
    for_each = var.persistence_enabled ? [1] : []
    content {
      persistence_mode    = "RDB"
      rdb_snapshot_period = var.rdb_snapshot_period
    }
  }
}
