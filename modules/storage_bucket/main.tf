resource "google_storage_bucket" "this" {
  name                     = var.name
  location                 = var.location
  force_destroy            = var.force_destroy_enabled
  public_access_prevention = var.public_access_prevention
  storage_class            = var.storage_class
  labels                   = var.common_labels

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "logging" {
    for_each = var.log_bucket_name != null ? [1] : []
    content {
      log_bucket        = var.log_bucket_name
      log_object_prefix = var.name
    }
  }

  dynamic "encryption" {
    for_each = var.encryption_kms_key_id != "" ? [1] : []
    content {
      default_kms_key_name = var.encryption_kms_key_id
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = try(lifecycle_rule.value.action.storage_class, null)
      }

      condition {
        age                        = try(lifecycle_rule.value.condition.age, null)
        created_before             = try(lifecycle_rule.value.condition.created_before, null)
        with_state                 = try(lifecycle_rule.value.condition.with_state, null)
        matches_storage_class      = try(lifecycle_rule.value.condition.matches_storage_class, null)
        matches_prefix             = try(lifecycle_rule.value.condition.matches_prefix, null)
        matches_suffix             = try(lifecycle_rule.value.condition.matches_suffix, null)
        num_newer_versions         = try(lifecycle_rule.value.condition.num_newer_versions, null)
        custom_time_before         = try(lifecycle_rule.value.condition.custom_time_before, null)
        days_since_custom_time     = try(lifecycle_rule.value.condition.days_since_custom_time, null)
        days_since_noncurrent_time = try(lifecycle_rule.value.condition.days_since_noncurrent_time, null)
        noncurrent_time_before     = try(lifecycle_rule.value.condition.noncurrent_time_before, null)
      }
    }
  }
}
