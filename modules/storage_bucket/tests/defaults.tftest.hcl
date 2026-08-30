# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name     = "test-app1-resources-bucket"
  location = "us-east1"
}

run "safe_defaults_are_applied" {
  command = plan

  assert {
    condition     = google_storage_bucket.this.public_access_prevention == "enforced"
    error_message = "Public access must be prevented by default"
  }

  assert {
    condition     = google_storage_bucket.this.force_destroy == false
    error_message = "A bucket holding objects must not be destroyed by default"
  }

  assert {
    condition     = length(google_storage_bucket.this.encryption) == 0
    error_message = "No encryption block must be set when no KMS key is given"
  }

  assert {
    condition     = length(google_storage_bucket.this.lifecycle_rule) == 0
    error_message = "No lifecycle rule must be created unless one is given"
  }
}

run "lifecycle_rules_are_created_from_the_input" {
  command = plan

  variables {
    versioning_enabled    = true
    encryption_kms_key_id = "projects/example-project/locations/us-east1/keyRings/test/cryptoKeys/test"
    lifecycle_rules = [
      {
        action    = { type = "Delete" }
        condition = { age = 30 }
      },
      {
        action    = { type = "SetStorageClass", storage_class = "NEARLINE" }
        condition = { age = 7 }
      }
    ]
  }

  assert {
    condition     = length(google_storage_bucket.this.lifecycle_rule) == 2
    error_message = "One rule must be created for every entry given"
  }

  assert {
    condition     = google_storage_bucket.this.versioning[0].enabled == true
    error_message = "Versioning must be enabled when it is asked for"
  }

  assert {
    condition     = length(google_storage_bucket.this.encryption) == 1
    error_message = "The encryption block must be set when a KMS key is given"
  }
}

run "uniform_bucket_level_access_is_on_by_default" {
  command = plan

  assert {
    condition     = google_storage_bucket.this.uniform_bucket_level_access == true
    error_message = "Access must be controlled by IAM alone rather than by per object ACLs"
  }
}

run "versioning_is_on_by_default" {
  command = plan

  assert {
    condition     = google_storage_bucket.this.versioning[0].enabled == true
    error_message = "Versioning must be on by default, so an overwritten object can be recovered"
  }
}
