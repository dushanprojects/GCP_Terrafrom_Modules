resource "google_sql_database_instance" "mysql" {
  # checkov:skip=CKV_GCP_6:The check looks for require_ssl, which Google removed from the provider in version 7. The instance enforces encryption through ssl_mode below
  name                 = var.name
  region               = var.region
  database_version     = var.database_version
  maintenance_version  = var.maintenance_version
  master_instance_name = var.master_instance_name
  root_password        = var.root_password
  encryption_key_name  = var.encryption_key_name
  deletion_protection  = var.deletion_protection

  settings {
    tier                        = var.tier
    edition                     = var.edition
    availability_type           = var.availability_type
    disk_type                   = var.disk_type
    disk_size                   = var.disk_size
    disk_autoresize             = var.disk_autoresize_enabled
    disk_autoresize_limit       = var.disk_autoresize_limit
    deletion_protection_enabled = var.api_deletion_protection_enabled
    user_labels                 = var.common_labels

    ip_configuration {
      ipv4_enabled                                  = var.public_ip_enabled
      private_network                               = var.private_network
      allocated_ip_range                            = var.allocated_ip_range
      enable_private_path_for_google_cloud_services = var.private_path_for_google_cloud_services_enabled
      ssl_mode                                      = var.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    dynamic "backup_configuration" {
      for_each = var.backup_enabled ? [1] : []
      content {
        enabled                        = true
        binary_log_enabled             = var.binary_log_enabled
        start_time                     = var.backup_start_time
        location                       = var.backup_location
        transaction_log_retention_days = var.transaction_log_retention_days

        backup_retention_settings {
          retained_backups = var.retained_backups
          retention_unit   = "COUNT"
        }
      }
    }

    dynamic "maintenance_window" {
      for_each = var.maintenance_window != null ? [var.maintenance_window] : []
      content {
        day          = maintenance_window.value.day
        hour         = maintenance_window.value.hour
        update_track = maintenance_window.value.update_track
      }
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "insights_config" {
      for_each = var.query_insights_enabled ? [1] : []
      content {
        query_insights_enabled  = true
        query_string_length     = var.query_string_length
        record_application_tags = var.record_application_tags
        record_client_address   = var.record_client_address
      }
    }
  }
}

# Databases created on the instance
resource "google_sql_database" "databases" {
  for_each = { for db in var.databases : db.name => db }

  name      = each.value.name
  instance  = google_sql_database_instance.mysql.name
  charset   = each.value.charset
  collation = each.value.collation
}

# Users granted access to the instance.
# var.users is declared sensitive, so it is unwrapped to key the resource by user
# name and the password alone is re-marked as sensitive.
resource "google_sql_user" "users" {
  for_each = { for user in nonsensitive(var.users) : user.name => user }

  name     = each.value.name
  instance = google_sql_database_instance.mysql.name
  host     = each.value.host
  password = sensitive(each.value.password)
}
