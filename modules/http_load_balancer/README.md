# HTTP Load Balancer Module

This Terraform module provisions an **external Google HTTPS Load Balancer** in front of a Cloud Run service using a shared module (`../../modules/http_load_balancer`). It reserves a public IP address, requests a Google managed certificate for your domains, connects the load balancer to the Cloud Run service through a serverless network endpoint group, redirects plain HTTP traffic to HTTPS, and optionally attaches a Cloud Armor security policy and Cloud CDN. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating the public load balancer for the Application 1 Cloud Run service
module "app1_load_balancer" {
  source = "../../modules/http_load_balancer"

  name                   = "dev-app1"
  region                 = var.region
  cloud_run_service_name = module.app1_cloud_run.name
  domains                = ["app1.example.com"]
  description            = "Public entry point of Application 1"

  security_policy_id    = module.app1_cloud_armor.id
  http_redirect_enabled = true

  request_logging_enabled     = true
  request_logging_sample_rate = 1

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                          | Description                                                                                  | Type           | Required |
|-------------------------------|------------------------------------------------------------------------------------------------|----------------|----------|
| `name`                        | The name used as the prefix of every load balancer resource                                   | `string`       | Yes      |
| `region`                      | The region the Cloud Run service runs in                                                      | `string`       | Yes      |
| `cloud_run_service_name`      | The name of the Cloud Run service the load balancer sends traffic to                          | `string`       | Yes      |
| `domains`                     | List of domains the Google managed certificate is issued for                                  | `list(string)` | Optional |
| `description`                 | A short description of what the load balancer serves                                          | `string`       | Optional |
| `ssl_certificate_id`          | The id of an existing SSL certificate. Leave unset to create a Google managed certificate     | `string`       | Optional |
| `ssl_policy_id`               | The id of the SSL policy that sets the minimum TLS version and the allowed ciphers            | `string`       | Optional |
| `security_policy_id`          | The id of the Cloud Armor security policy attached to the backend service                     | `string`       | Optional |
| `http_redirect_enabled`       | Whether plain HTTP traffic is redirected to HTTPS (default `true`)                            | `bool`         | Optional |
| `backend_timeout_sec`         | The time in seconds the backend is allowed to take before the request fails                   | `number`       | Optional |
| `request_logging_enabled`     | Whether the load balancer writes request logs to Cloud Logging                                | `bool`         | Optional |
| `request_logging_sample_rate` | The share of requests written to the logs, from 0 to 1                                        | `number`       | Optional |
| `cdn_enabled`                 | Whether Cloud CDN caches the responses of the backend                                         | `bool`         | Optional |
| `cdn_cache_mode`              | What Cloud CDN caches                                                                         | `string`       | Optional |
| `cdn_default_ttl`             | The default time in seconds a response is cached for                                          | `number`       | Optional |
| `cdn_max_ttl`                 | The longest time in seconds a response is cached for                                          | `number`       | Optional |

## Outputs

| Name                   | Description                                                                           |
|------------------------|---------------------------------------------------------------------------------------|
| `ip_address`           | The public IP address of the load balancer                                            |
| `backend_service_id`   | The full ID of the backend service                                                    |
| `backend_service_name` | The name of the backend service                                                       |
| `url_map_id`           | The full ID of the URL map                                                            |
| `ssl_certificate_id`   | The full ID of the SSL certificate served by the load balancer                        |

## Notes

- A Google managed certificate is only issued after the DNS A record of every domain points at the `ip_address` output. Until then the certificate stays in the `PROVISIONING` state and the load balancer answers HTTPS requests with a certificate error. Provisioning usually takes between 15 and 60 minutes after the DNS record is in place.
- Either set `domains` for a Google managed certificate, or pass an existing certificate through `ssl_certificate_id`.
- The Cloud Run service should use the `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` ingress setting so that clients cannot skip the load balancer and reach the service on its own URL.
- The Cloud Run service also needs `allUsers` in its invokers list when the load balancer serves public traffic.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/http_load_balancer`):

```
terraform init -backend=false
terraform test
```

The `init` is needed even though the provider is mocked, because Terraform reads the provider schema to check the resource arguments. Useful options while working on the module:

```
terraform test -verbose                        # show the plan behind every test case
terraform test -filter=tests/defaults.tftest.hcl   # run a single test file
```

A failing test prints the message written on the assertion, so the output says what the module should have done rather than only which line failed.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating load balancer resources and certificates
- A Cloud Run service in the same region
- Google Service APIs `compute.googleapis.com` and `run.googleapis.com` should be enabled
---
