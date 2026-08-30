# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name   = "test-app1-cache"
  region = "us-east1"
}

run "safe_defaults_are_applied" {
  command = plan

  assert {
    condition     = google_redis_instance.this.tier == "STANDARD_HA"
    error_message = "A replicated instance must be created by default"
  }

  assert {
    condition     = google_redis_instance.this.auth_enabled == true
    error_message = "Clients must have to send an auth string by default"
  }

  assert {
    condition     = google_redis_instance.this.transit_encryption_mode == "SERVER_AUTHENTICATION"
    error_message = "The traffic to the instance must be encrypted by default"
  }

  assert {
    condition     = google_redis_instance.this.connect_mode == "PRIVATE_SERVICE_ACCESS"
    error_message = "The instance must be reached over private service access by default"
  }

  assert {
    condition     = length(google_redis_instance.this.persistence_config) == 1
    error_message = "Snapshots must be taken by default so the data survives a restart"
  }

  assert {
    condition     = length(google_redis_instance.this.maintenance_policy) == 0
    error_message = "No maintenance window must be set when the input is not given"
  }
}

run "the_maintenance_window_is_set_when_given" {
  command = plan

  variables {
    maintenance_window = {
      day  = "SUNDAY"
      hour = 3
    }
  }

  assert {
    condition     = google_redis_instance.this.maintenance_policy[0].weekly_maintenance_window[0].day == "SUNDAY"
    error_message = "The maintenance window must use the day given"
  }

  assert {
    condition     = google_redis_instance.this.maintenance_policy[0].weekly_maintenance_window[0].start_time[0].hours == 3
    error_message = "The maintenance window must use the hour given"
  }
}

run "persistence_can_be_turned_off" {
  command = plan

  variables {
    persistence_enabled = false
  }

  assert {
    condition     = length(google_redis_instance.this.persistence_config) == 0
    error_message = "No snapshot settings must be applied when persistence is turned off"
  }
}
