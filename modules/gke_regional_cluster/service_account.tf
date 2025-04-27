resource "google_service_account" "nodepool" {
  account_id   = lower("${var.cluster_name}-sa")
  display_name = "${var.cluster_name} GKE Nodepool Service Account"
}

resource "google_project_iam_binding" "gcr_read_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.nodepool.email}"
  ]
}

resource "google_project_iam_binding" "artifact_read_access" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_service_account.nodepool.email}"
  ]
}
