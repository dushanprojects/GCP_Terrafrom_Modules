# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name                  = "test-dev"
  region                = "us-east1"
  public_ip_cidr_range  = "10.10.0.0/24"
  private_ip_cidr_range = "10.10.1.0/24"
  common_labels         = { team = "sre" }
}

run "a_vpc_without_gke_ranges_has_no_secondary_ranges" {
  command = plan

  assert {
    condition     = length(google_compute_subnetwork.private_subnet.secondary_ip_range) == 0
    error_message = "A VPC used by services other than GKE must not carry empty secondary ranges"
  }

  assert {
    condition     = google_compute_network.vpc.auto_create_subnetworks == false
    error_message = "The subnets must be created by this module rather than by Google"
  }

  assert {
    condition     = google_compute_subnetwork.private_subnet.private_ip_google_access == true
    error_message = "The private subnet must be able to reach the Google APIs"
  }
}

run "gke_ranges_are_added_when_given" {
  command = plan

  variables {
    pod_ip_cidr_range      = "172.30.192.0/18"
    services_ip_cidr_range = "172.30.128.0/18"
  }

  assert {
    condition     = length(google_compute_subnetwork.private_subnet.secondary_ip_range) == 2
    error_message = "Both GKE ranges must be created when they are given"
  }

  assert {
    condition     = contains([for range in google_compute_subnetwork.private_subnet.secondary_ip_range : range.range_name], "k8s-pod-range")
    error_message = "The pod range must keep its name so existing clusters are not rebuilt"
  }
}

run "no_ephemeral_port_range_is_open_to_the_internet" {
  command = plan

  assert {
    condition = alltrue([
      for rule in google_compute_firewall.allow_public_traffic.allow :
      alltrue([for port in rule.ports : !strcontains(port, "1024-")])
    ])
    error_message = "The public firewall rule must not open the ephemeral port range to the internet"
  }

  assert {
    condition     = google_compute_firewall.allow_public_traffic.source_ranges == toset(["0.0.0.0/0"])
    error_message = "The public rule is the only rule that accepts traffic from the internet"
  }
}

run "flow_logs_are_off_by_default_and_can_be_turned_on" {
  command = plan

  assert {
    condition     = length(google_compute_subnetwork.private_subnet.log_config) == 0
    error_message = "Flow logs must stay off unless they are asked for, because they are charged per GB"
  }
}

run "flow_logs_are_created_when_enabled" {
  command = plan

  variables {
    flow_logs_enabled = true
  }

  assert {
    condition     = google_compute_subnetwork.private_subnet.log_config[0].flow_sampling == 0.5
    error_message = "The flow logs must use the sampling rate given"
  }
}
