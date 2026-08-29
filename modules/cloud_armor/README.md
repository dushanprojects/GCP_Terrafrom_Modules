# Cloud Armor Module

This Terraform module provisions a **Google Cloud Armor security policy** using a shared module (`../../modules/cloud_armor`). The policy is attached to a backend service of an external load balancer and filters the traffic before it reaches the application. You can block or allow IP ranges, apply the preconfigured WAF rules for common attacks such as SQL injection and cross site scripting, limit how many requests a single client can send, and turn on Adaptive Protection. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating the security policy for the Application 1 load balancer
module "app1_cloud_armor" {
  source = "../../modules/cloud_armor"

  name        = "dev-app1-security-policy"
  description = "Protects the Application 1 load balancer"

  default_rule_action         = "allow"
  adaptive_protection_enabled = true

  denied_ip_ranges = [
    "192.0.2.0/24"
  ]

  waf_rules = [
    {
      expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      action     = "deny(403)"
    },
    {
      expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      action     = "deny(403)"
      preview    = true
    }
  ]

  rate_limit_threshold_count = 100
  rate_limit_interval_sec    = 60

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                                  | Description                                                                          | Type           | Required |
|---------------------------------------|----------------------------------------------------------------------------------------|----------------|----------|
| `name`                                | The name of the Cloud Armor security policy                                           | `string`       | Yes      |
| `description`                         | A short description of what the security policy protects                              | `string`       | Optional |
| `type`                                | The type of the security policy                                                       | `string`       | Optional |
| `default_rule_action`                 | The action applied when no other rule matches (default `allow`)                       | `string`       | Optional |
| `adaptive_protection_enabled`         | Whether Adaptive Protection watches for layer 7 attacks                               | `bool`         | Optional |
| `adaptive_protection_rule_visibility` | How much detail Adaptive Protection reports (STANDARD\|PREMIUM)                       | `string`       | Optional |
| `denied_ip_ranges`                    | List of IP ranges in CIDR notation that are blocked                                   | `list(string)` | Optional |
| `allowed_ip_ranges`                   | List of IP ranges in CIDR notation that are allowed                                   | `list(string)` | Optional |
| `waf_rules`                           | List of preconfigured WAF rules applied to the traffic                                | `list(object)` | Optional |
| `rate_limit_threshold_count`          | The number of requests a single client is allowed to send in the interval             | `number`       | Optional |
| `rate_limit_interval_sec`             | The length of the rate limit interval in seconds                                      | `number`       | Optional |
| `rate_limit_enforce_on_key`           | What the rate limit is counted against (IP\|ALL\|HTTP_HEADER\|XFF_IP\|HTTP_COOKIE)    | `string`       | Optional |
| `rate_limit_ban_duration_sec`         | How long a client is banned for in seconds after it passes the rate limit             | `number`       | Optional |

## Outputs

| Name        | Description                                     |
|-------------|-------------------------------------------------|
| `id`        | The full ID of the Cloud Armor security policy  |
| `name`      | The name of the Cloud Armor security policy     |
| `self_link` | The URI of the created resource                 |

## Notes

- Rules are applied in priority order. The blocked ranges use priorities from 1000, the allowed ranges from 2000, the WAF rules from 3000 and the rate limit rule uses 4000.
- Set `preview` to `true` on a WAF rule to log what the rule would block without blocking it. Review the results in Cloud Logging before you enforce the rule.
- To allow only a known set of clients, set `default_rule_action` to `deny(403)` and list the client ranges in `allowed_ip_ranges`.
- Adaptive Protection is a Cloud Armor Enterprise feature and is charged separately.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/cloud_armor`):

```
terraform init -backend=false
terraform test
```

The `init` is needed even though the provider is mocked, because Terraform reads the provider schema to check the resource arguments. Useful options while working on the module:

```
terraform test -verbose                        # show the plan behind every test case
terraform test -filter=tests/rules.tftest.hcl   # run a single test file
```

A failing test prints the message written on the assertion, so the output says what the module should have done rather than only which line failed.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating Cloud Armor security policies
- Google Service API `compute.googleapis.com` should be enabled
---
