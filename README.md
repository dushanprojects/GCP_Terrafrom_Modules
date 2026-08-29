# GCP Terraform Modules and Common Examples

This repository contains a collection of reusable and practical Terraform modules and examples for Google Cloud Platform (GCP).  
Each module demonstrates common patterns and best practices to help you quickly build reliable infrastructure on GCP.

Infrastructure, DevOps and SRE teams tend to build the same platform out of the same handful of GCP services. This repository provides a module for each of those services, and examples that wire them together the way they are normally used.

The modules hold the resources and the sensible defaults. The examples show a complete working setup for a common scenario and are the quickest way to see how the modules fit together.

These examples are intended to be used as templates or references for your own projects.  
Feel free to customize them according to your needs.

## Modules

### Project setup

| Module | Description |
|--------|-------------|
| [`enable_services`](modules/enable_services) | Enables the Google Service APIs a project needs before any other resource is created |

### Networking and traffic

| Module | Description |
|--------|-------------|
| [`vpc`](modules/vpc) | A custom VPC with public and private subnets, Cloud Router, Cloud NAT and the firewall rules |
| [`http_load_balancer`](modules/http_load_balancer) | An external HTTPS load balancer in front of a Cloud Run service, with a Google managed certificate and an HTTP to HTTPS redirect |
| [`cloud_armor`](modules/cloud_armor) | A Cloud Armor security policy with IP rules, preconfigured WAF rules and rate limiting |

### Compute and runtime

| Module | Description |
|--------|-------------|
| [`gke_regional_cluster`](modules/gke_regional_cluster) | A regional GKE cluster with its own service account, node pools and cluster firewall rules |
| [`cloud_run`](modules/cloud_run) | A Cloud Run service with scaling, health checks, secret environment variables and VPC egress |
| [`cloud_function`](modules/cloud_function) | A Cloud Function for scheduled and event driven tasks |

### Data and storage

| Module | Description |
|--------|-------------|
| [`db_mysql`](modules/db_mysql) | A Cloud SQL for MySQL instance with private IP, high availability, backups and point in time recovery |
| [`memorystore_redis`](modules/memorystore_redis) | A Memorystore for Redis cache reached privately from your own VPC |
| [`storage_bucket`](modules/storage_bucket) | A storage bucket with versioning, access logs, lifecycle rules and optional CMEK encryption |

### Security and identity

| Module | Description |
|--------|-------------|
| [`service_account`](modules/service_account) | A service account with its project roles and Workload Identity bindings |
| [`secret_manager`](modules/secret_manager) | A Secret Manager secret with replication, rotation notifications and read access for the applications that need it |
| [`kms_key_ring`](modules/kms_key_ring) | A KMS key ring shared by the keys of a location |
| [`kms_key`](modules/kms_key) | A KMS crypto key with automatic rotation and the IAM bindings used for CMEK encryption |

### Build and delivery

| Module | Description |
|--------|-------------|
| [`artifact_registry`](modules/artifact_registry) | A container image or package repository with immutable tags and cleanup policies |

### Observability

| Module | Description |
|--------|-------------|
| [`monitoring_alerts`](modules/monitoring_alerts) | Notification channels, uptime checks and alert policies for the services above |

## Examples

| Example | What it shows |
|---------|---------------|
| [`vpc_custom`](examples/vpc_custom) | A custom VPC with public and private subnets, Cloud NAT and the secondary ranges used by GKE |
| [`gke_clusters/regional_cluster_default_vpc`](examples/gke_clusters/regional_cluster_default_vpc) | A regional GKE cluster on the default VPC |
| [`gke_clusters/regional_private_cluster_custom_vpc`](examples/gke_clusters/regional_private_cluster_custom_vpc) | A regional private GKE cluster on a custom VPC |
| [`cloud_run_service`](examples/cloud_run_service) | A container published safely, using a service account, an image repository, a secret, Cloud Run, Cloud Armor and an external HTTPS load balancer |
| [`db_mysql_private`](examples/db_mysql_private) | A private, highly available MySQL instance reached over private services access |
| [`memorystore_redis`](examples/memorystore_redis) | A private Redis cache with its auth string stored in Secret Manager |
| [`storage_bucket_simple`](examples/storage_bucket_simple) | A storage bucket with the common settings |
| [`storage_bucket_encrypted`](examples/storage_bucket_encrypted) | A storage bucket encrypted with a customer managed KMS key |
| [`kms_keys`](examples/kms_keys) | A KMS key ring and the crypto keys used by other services |
| [`monitoring_alerts`](examples/monitoring_alerts) | Uptime checks and alert policies covering Cloud Run and Cloud SQL |
| [`cloudfunction_delete_unused_regional_disks`](examples/cloudfunction_delete_unused_regional_disks) | A scheduled Cloud Function that removes unused regional disks |
| [`cloudfunction_delete_unused_zonal_disks`](examples/cloudfunction_delete_unused_zonal_disks) | A scheduled Cloud Function that removes unused zonal disks |

## Repository layout

```
modules/    The reusable modules. Each one holds main.tf, variables.tf, outputs.tf and a README
examples/   Complete working setups that call the modules the way they are normally used
```

## Getting started

1. Pick the example closest to what you need and open its README.
2. Set the `project_id` and `region` variables in the `variables.tf` file of that example.
3. Run `terraform init`, then `terraform plan` to review the changes, then `terraform apply`.

Every example enables the Google Service APIs it needs through the `enable_services` module, so a new project can be built from an empty state.

## Tests

Most modules carry their own tests, written with the Terraform test framework that ships with Terraform itself. The tests sit in the `tests` directory of each module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP. They check the behaviour that fails quietly, such as a default that must stay safe, an optional block that must be left out when its input is not given, and an input that must be rejected.

Run the tests of one module:

```
cd modules/db_mysql
terraform init -backend=false
terraform test
```

Run the tests of every module that has them:

```
for dir in $(find modules -type d -name tests); do
  module=$(dirname "$dir")
  echo "--- $module"
  terraform -chdir="$module" init -backend=false >/dev/null
  terraform -chdir="$module" test
done
```

Useful options while working on a module:

```
terraform test -verbose                     # show the plan behind every test case
terraform test -filter=tests/defaults.tftest.hcl   # run a single test file
```

The `init` is needed even though the provider is mocked, because Terraform reads the provider schema to check the resource arguments.

## Quality checks

The checks below run on every pull request through the workflow in `.github/workflows/terraform.yml`.

| Check    | What it does                                                                    |
|----------|---------------------------------------------------------------------------------|
| Format   | `terraform fmt -check -recursive` over the whole repository                      |
| Validate | `terraform validate` in every module and example                                 |
| Test     | `terraform test` in every module that has a `tests` directory                    |
| Lint     | TFLint with the Terraform and Google rule sets, configured in `.tflint.hcl`      |
| Security | Checkov and Trivy scan the configuration for insecure settings                   |

Run all of them locally before pushing:

```
./bin/quality_checks.sh
```

The script skips TFLint and the security scanners when they are not installed, so the format, validate and test checks still run without them.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.10
- GCP project with billing enabled
- Credentials with the IAM permissions the resources need, usually through `gcloud auth application-default login` or a service account key

The modules declare the provider versions they are tested against, currently `hashicorp/google` from 6.0 up to but not including 9.0.

# Contributions

© 2025 Dushan Wijesinghe - Licensed under the MIT License.

You’re welcome to use, modify, and contribute improvements.  
Please keep contributions aligned with the original example structure and purpose.
