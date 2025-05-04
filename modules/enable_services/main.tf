resource "google_project_service" "services" {
  for_each = toset(var.apis)

  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = true
}
