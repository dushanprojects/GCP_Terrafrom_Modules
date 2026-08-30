# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name   = "test-app1-mysql"
  region = "us-east1"
}

run "safe_defaults_are_applied" {
  command = plan

  assert {
    condition     = google_sql_database_instance.mysql.deletion_protection == true
    error_message = "The instance must be protected from Terraform deletion by default"
  }

  assert {
    condition     = google_sql_database_instance.mysql.settings[0].deletion_protection_enabled == true
    error_message = "The instance must be protected from API and Console deletion by default"
  }

  assert {
    condition     = google_sql_database_instance.mysql.settings[0].ip_configuration[0].ipv4_enabled == false
    error_message = "The instance must not be given a public IP address by default"
  }

  assert {
    condition     = google_sql_database_instance.mysql.settings[0].ip_configuration[0].ssl_mode == "ENCRYPTED_ONLY"
    error_message = "Connections must be encrypted by default"
  }

  assert {
    condition     = length(google_sql_database_instance.mysql.settings[0].backup_configuration) == 1
    error_message = "Automated backups must be enabled by default"
  }

  assert {
    condition     = google_sql_database_instance.mysql.settings[0].backup_configuration[0].binary_log_enabled == true
    error_message = "Binary logging must be enabled by default so point in time recovery works"
  }
}

run "replica_can_turn_backups_off" {
  command = plan

  variables {
    master_instance_name = "test-app1-mysql"
    backup_enabled       = false
  }

  assert {
    condition     = length(google_sql_database_instance.mysql.settings[0].backup_configuration) == 0
    error_message = "A read replica must be able to run without a backup configuration"
  }
}

run "optional_blocks_are_left_out_when_unset" {
  command = plan

  assert {
    condition     = length(google_sql_database_instance.mysql.settings[0].maintenance_window) == 0
    error_message = "No maintenance window must be set when the input is not given"
  }

  assert {
    condition     = length(google_sql_database_instance.mysql.settings[0].database_flags) == 0
    error_message = "No database flags must be set when the input is not given"
  }

  assert {
    condition     = length(google_sql_database_instance.mysql.settings[0].insights_config) == 0
    error_message = "Query Insights must stay off when the input is not given"
  }

  assert {
    condition     = length(google_sql_database_instance.mysql.settings[0].ip_configuration[0].authorized_networks) == 0
    error_message = "No authorized networks must be set when the input is not given"
  }
}

run "databases_and_users_are_keyed_by_name" {
  command = plan

  variables {
    databases = [
      { name = "app1" },
      { name = "reporting" }
    ]
    users = [
      { name = "app1", password = "an-example-password" }
    ]
  }

  assert {
    condition     = length(google_sql_database.databases) == 2
    error_message = "One database must be created for every entry in the databases input"
  }

  assert {
    condition     = google_sql_database.databases["app1"].charset == "utf8mb4"
    error_message = "The default charset must be utf8mb4"
  }

  assert {
    condition     = google_sql_user.users["app1"].host == "%"
    error_message = "A user must be reachable from any host unless a host is given"
  }
}
