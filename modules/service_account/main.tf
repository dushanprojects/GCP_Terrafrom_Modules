resource "google_service_account" "this" {
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
}

# Project level roles granted to the service account
resource "google_project_iam_member" "project_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}

# Allows a Kubernetes service account to impersonate this service account
resource "google_service_account_iam_member" "workload_identity_users" {
  for_each = toset(var.workload_identity_users)

  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}

# Allows other members to impersonate this service account
resource "google_service_account_iam_member" "token_creators" {
  for_each = toset(var.token_creators)

  service_account_id = google_service_account.this.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
