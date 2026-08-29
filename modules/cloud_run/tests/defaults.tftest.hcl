# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name     = "test-app1"
  location = "us-east1"
  image    = "us-docker.pkg.dev/cloudrun/container/hello"
}

run "safe_defaults_are_applied" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.this.ingress == "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    error_message = "Only the load balancer must reach the service by default"
  }

  assert {
    condition     = google_cloud_run_v2_service.this.deletion_protection == true
    error_message = "The service must be protected from deletion by default"
  }

  assert {
    condition     = length(google_cloud_run_v2_service_iam_member.invokers) == 0
    error_message = "Nobody must be allowed to call the service unless an invoker is given"
  }

  assert {
    condition     = length(google_cloud_run_v2_service.this.template[0].vpc_access) == 0
    error_message = "Outbound traffic must not be sent through a VPC unless a network is given"
  }

  assert {
    condition     = length(google_cloud_run_v2_service.this.template[0].containers[0].startup_probe) == 0
    error_message = "No startup probe must be set when no path is given"
  }
}

run "environment_variables_are_passed_to_the_container" {
  command = plan

  variables {
    environment_variables = {
      APP_ENVIRONMENT = "development"
      LOG_LEVEL       = "info"
    }
    secret_environment_variables = [
      { name = "APP_API_KEY", secret_id = "test-app1-api-key" }
    ]
  }

  assert {
    condition     = length(google_cloud_run_v2_service.this.template[0].containers[0].env) == 3
    error_message = "Both the plain and the secret environment variables must be passed to the container"
  }
}

run "vpc_egress_is_configured_when_a_network_is_given" {
  command = plan

  variables {
    vpc_network    = "projects/example-project/global/networks/test-vpc"
    vpc_subnetwork = "projects/example-project/regions/us-east1/subnetworks/test-subnet"
  }

  assert {
    condition     = google_cloud_run_v2_service.this.template[0].vpc_access[0].egress == "PRIVATE_RANGES_ONLY"
    error_message = "Only private traffic must be sent through the VPC by default"
  }
}

run "a_public_service_allows_all_users" {
  command = plan

  variables {
    ingress  = "INGRESS_TRAFFIC_ALL"
    invokers = ["allUsers"]
  }

  assert {
    condition     = google_cloud_run_v2_service_iam_member.invokers["allUsers"].role == "roles/run.invoker"
    error_message = "A public service must grant the invoker role to all users"
  }
}
