# The tests run against a mocked provider, so they need no GCP credentials
# and no resources are created

mock_provider "google" {}

variables {
  name = "test-app1-security-policy"
}

run "only_the_default_rule_exists_when_nothing_is_given" {
  command = plan

  assert {
    condition     = length(google_compute_security_policy.this.rule) == 1
    error_message = "A policy with no inputs must only hold the default rule"
  }

  assert {
    condition     = one([for rule in google_compute_security_policy.this.rule : rule.priority if rule.action == "allow"]) == 2147483647
    error_message = "The default rule must sit at the lowest priority"
  }
}

run "rules_are_ordered_by_type" {
  # The rule set holds values the provider computes, so the assertions need an
  # apply. The provider is mocked, so nothing is created in GCP
  command = apply

  variables {
    denied_ip_ranges  = ["192.0.2.0/24", "198.51.100.0/24"]
    allowed_ip_ranges = ["203.0.113.0/24"]
    waf_rules = [
      { expression = "evaluatePreconfiguredExpr('sqli-v33-stable')" },
      { expression = "evaluatePreconfiguredExpr('xss-v33-stable')", preview = true }
    ]
    rate_limit_threshold_count = 100
  }

  assert {
    condition     = length(google_compute_security_policy.this.rule) == 7
    error_message = "Every input rule plus the default rule must be created"
  }

  assert {
    condition     = length([for rule in google_compute_security_policy.this.rule : rule if rule.priority >= 1000 && rule.priority < 2000]) == 2
    error_message = "The denied ranges must use the priorities from 1000"
  }

  assert {
    condition     = length([for rule in google_compute_security_policy.this.rule : rule if rule.priority >= 3000 && rule.priority < 4000]) == 2
    error_message = "The WAF rules must use the priorities from 3000"
  }

  assert {
    condition     = one([for rule in google_compute_security_policy.this.rule : rule.action if rule.priority == 4000]) == "rate_based_ban"
    error_message = "The rate limit rule must sit at priority 4000"
  }
}

run "a_deny_by_default_policy_can_be_built" {
  command = apply

  variables {
    default_rule_action = "deny(403)"
    allowed_ip_ranges   = ["203.0.113.0/24"]
  }

  assert {
    condition     = one([for rule in google_compute_security_policy.this.rule : rule.action if rule.priority == 2147483647]) == "deny(403)"
    error_message = "The default rule must deny the traffic when the policy allows known clients only"
  }
}
