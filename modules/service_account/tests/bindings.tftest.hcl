# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  project_id = "example-project"
  account_id = "test-app1-run"
}

run "no_roles_are_granted_by_default" {
  command = plan

  assert {
    condition     = length(google_project_iam_member.project_roles) == 0
    error_message = "A service account must start with no project roles"
  }

  assert {
    condition     = length(google_service_account_iam_member.workload_identity_users) == 0
    error_message = "Nobody must be able to use the service account through Workload Identity by default"
  }
}

run "project_roles_are_granted_to_the_service_account" {
  command = plan

  variables {
    project_roles = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter"
    ]
  }

  assert {
    condition     = length(google_project_iam_member.project_roles) == 2
    error_message = "One binding must be created for every role given"
  }

  assert {
    condition     = google_project_iam_member.project_roles["roles/logging.logWriter"].project == "example-project"
    error_message = "The roles must be granted in the project given"
  }
}

run "workload_identity_users_get_the_right_role" {
  command = plan

  variables {
    workload_identity_users = ["serviceAccount:example-project.svc.id.goog[default/app1]"]
  }

  assert {
    condition     = google_service_account_iam_member.workload_identity_users["serviceAccount:example-project.svc.id.goog[default/app1]"].role == "roles/iam.workloadIdentityUser"
    error_message = "A Workload Identity user must be granted the workload identity user role"
  }
}
