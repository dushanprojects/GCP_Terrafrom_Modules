# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name                   = "test-app1"
  region                 = "us-east1"
  cloud_run_service_name = "test-app1"
  domains                = ["app1.example.com"]
}

run "safe_defaults_are_applied" {
  command = plan

  assert {
    condition     = google_compute_backend_service.this.load_balancing_scheme == "EXTERNAL_MANAGED"
    error_message = "The backend service must use the global external load balancing scheme"
  }

  assert {
    condition     = google_compute_backend_service.this.log_config[0].enable == true
    error_message = "Request logging must be enabled by default"
  }

  assert {
    condition     = length(google_compute_managed_ssl_certificate.this) == 1
    error_message = "A Google managed certificate must be created when no certificate is given"
  }

  assert {
    condition     = length(google_compute_global_forwarding_rule.http) == 1
    error_message = "Plain HTTP traffic must be redirected to HTTPS by default"
  }

  assert {
    condition     = google_compute_region_network_endpoint_group.serverless.network_endpoint_type == "SERVERLESS"
    error_message = "The load balancer must reach Cloud Run through a serverless network endpoint group"
  }

  assert {
    condition     = length(google_compute_backend_service.this.cdn_policy) == 0
    error_message = "Cloud CDN must stay off unless it is asked for"
  }
}

run "an_existing_certificate_is_used_when_given" {
  command = plan

  variables {
    ssl_certificate_id = "projects/example-project/global/sslCertificates/existing"
  }

  assert {
    condition     = length(google_compute_managed_ssl_certificate.this) == 0
    error_message = "No managed certificate must be created when an existing certificate is given"
  }
}

run "the_http_redirect_can_be_turned_off" {
  command = plan

  variables {
    http_redirect_enabled = false
  }

  assert {
    condition     = length(google_compute_global_forwarding_rule.http) == 0
    error_message = "No HTTP forwarding rule must be created when the redirect is turned off"
  }
}
