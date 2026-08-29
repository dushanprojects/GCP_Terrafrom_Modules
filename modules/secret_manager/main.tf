resource "google_secret_manager_secret" "this" {
  secret_id = var.secret_id
  labels    = var.common_labels

  dynamic "replication" {
    for_each = length(var.replica_locations) == 0 ? [1] : []
    content {
      auto {
        dynamic "customer_managed_encryption" {
          for_each = var.encryption_kms_key_id != null ? [1] : []
          content {
            kms_key_name = var.encryption_kms_key_id
          }
        }
      }
    }
  }

  dynamic "replication" {
    for_each = length(var.replica_locations) > 0 ? [1] : []
    content {
      user_managed {
        dynamic "replicas" {
          for_each = var.replica_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }

  dynamic "rotation" {
    for_each = var.rotation_period != null ? [1] : []
    content {
      rotation_period    = var.rotation_period
      next_rotation_time = var.next_rotation_time
    }
  }

  dynamic "topics" {
    for_each = var.notification_topics
    content {
      name = topics.value
    }
  }
}

# The initial value of the secret. Leave initial_version_enabled false when the
# value is added outside of Terraform, so the secret is created empty
resource "google_secret_manager_secret_version" "initial" {
  count = var.initial_version_enabled ? 1 : 0

  secret      = google_secret_manager_secret.this.id
  secret_data = var.secret_data
  enabled     = true
}

# Members allowed to read the secret value
resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each = toset(var.accessors)

  secret_id = google_secret_manager_secret.this.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}

# Additional role bindings on the secret
resource "google_secret_manager_secret_iam_member" "additional_bindings" {
  for_each = { for x, binding in var.additional_iam_bindings : tostring(x) => binding }

  secret_id = google_secret_manager_secret.this.secret_id
  role      = each.value.role
  member    = each.value.member
}
