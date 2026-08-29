resource "google_artifact_registry_repository" "this" {
  repository_id = var.repository_id
  location      = var.location
  format        = var.format
  mode          = var.mode
  description   = var.description
  kms_key_name  = var.encryption_kms_key_id
  labels        = var.common_labels

  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" && var.immutable_tags_enabled ? [1] : []
    content {
      immutable_tags = true
    }
  }

  # Deletes images that are older than the retention period
  dynamic "cleanup_policies" {
    for_each = var.delete_older_than != null ? [1] : []
    content {
      id     = "delete-old-images"
      action = "DELETE"
      condition {
        tag_state  = var.delete_untagged_only ? "UNTAGGED" : "ANY"
        older_than = var.delete_older_than
      }
    }
  }

  # Keeps the most recent images regardless of the delete policy above
  dynamic "cleanup_policies" {
    for_each = var.keep_most_recent_count != null ? [1] : []
    content {
      id     = "keep-most-recent"
      action = "KEEP"
      most_recent_versions {
        keep_count = var.keep_most_recent_count
      }
    }
  }
}

# Additional role bindings on the repository
resource "google_artifact_registry_repository_iam_member" "additional_bindings" {
  for_each = { for x, binding in var.additional_iam_bindings : "${x}" => binding }

  project    = google_artifact_registry_repository.this.project
  location   = google_artifact_registry_repository.this.location
  repository = google_artifact_registry_repository.this.name
  role       = each.value.role
  member     = each.value.member
}
