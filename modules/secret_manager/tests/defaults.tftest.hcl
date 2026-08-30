# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  secret_id = "test-app1-api-key"
}

run "no_version_is_created_by_default" {
  command = plan

  assert {
    condition     = length(google_secret_manager_secret_version.initial) == 0
    error_message = "The secret must be created empty unless an initial version is asked for"
  }

  assert {
    condition     = length(google_secret_manager_secret.this.replication[0].auto) == 1
    error_message = "Replication must be managed by Google unless replica locations are given"
  }
}

run "initial_version_is_created_when_enabled" {
  command = plan

  variables {
    initial_version_enabled = true
    secret_data             = "an-example-value"
  }

  assert {
    condition     = length(google_secret_manager_secret_version.initial) == 1
    error_message = "An initial version must be created when the flag is enabled"
  }
}

run "user_managed_replication_uses_the_given_locations" {
  command = plan

  variables {
    replica_locations = ["us-east1", "us-central1"]
  }

  assert {
    condition     = length(google_secret_manager_secret.this.replication[0].auto) == 0
    error_message = "Automatic replication must not be used when replica locations are given"
  }

  assert {
    condition     = length(google_secret_manager_secret.this.replication[0].user_managed[0].replicas) == 2
    error_message = "One replica must be created for every location given"
  }
}

run "accessors_are_granted_the_accessor_role" {
  command = plan

  variables {
    accessors = ["serviceAccount:app1@example-project.iam.gserviceaccount.com"]
  }

  assert {
    condition     = google_secret_manager_secret_iam_member.accessors["serviceAccount:app1@example-project.iam.gserviceaccount.com"].role == "roles/secretmanager.secretAccessor"
    error_message = "An accessor must be granted the secret accessor role"
  }
}

run "rotation_without_a_topic_is_rejected" {
  command = plan

  variables {
    rotation_period = "7776000s"
  }

  expect_failures = [var.rotation_period]
}
