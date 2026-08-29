# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  repository_id = "test-app1-images"
  location      = "us-east1"
}

run "safe_defaults_are_applied" {
  command = plan

  assert {
    condition     = google_artifact_registry_repository.this.format == "DOCKER"
    error_message = "A container image repository must be created by default"
  }

  assert {
    condition     = google_artifact_registry_repository.this.cleanup_policy_dry_run == true
    error_message = "Cleanup policies must only report what they would delete until they are reviewed"
  }

  assert {
    condition     = length(google_artifact_registry_repository.this.cleanup_policies) == 0
    error_message = "No cleanup policy must be created unless one is asked for"
  }

  assert {
    condition     = length(google_artifact_registry_repository.this.docker_config) == 0
    error_message = "Image tags must stay changeable unless immutable tags are asked for"
  }
}

run "cleanup_policies_are_created_when_asked_for" {
  command = plan

  variables {
    delete_older_than      = "2592000s"
    keep_most_recent_count = 10
    cleanup_policy_dry_run = false
    immutable_tags_enabled = true
  }

  assert {
    condition     = length(google_artifact_registry_repository.this.cleanup_policies) == 2
    error_message = "A delete policy and a keep policy must be created"
  }

  assert {
    condition     = google_artifact_registry_repository.this.docker_config[0].immutable_tags == true
    error_message = "Image tags must be immutable when it is asked for"
  }
}

run "immutable_tags_are_ignored_for_other_formats" {
  command = plan

  variables {
    format                 = "MAVEN"
    immutable_tags_enabled = true
  }

  assert {
    condition     = length(google_artifact_registry_repository.this.docker_config) == 0
    error_message = "The Docker settings must not be applied to a repository of another format"
  }
}
