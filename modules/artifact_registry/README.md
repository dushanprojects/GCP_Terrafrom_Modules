# Artifact Registry Module

This Terraform module provisions a **Google Artifact Registry repository** using a shared module (`../../modules/artifact_registry`). You can create a repository for container images or language packages, encrypt it with a customer managed KMS key, prevent image tags from being overwritten, apply cleanup policies that remove old images, and grant additional IAM bindings to build pipelines or runtime service accounts. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating a container image repository for Application 1
module "app1_artifact_registry" {
  source = "../../modules/artifact_registry"

  repository_id = "dev-app1-images"
  location      = var.region
  format        = "DOCKER"
  description   = "Container images of Application 1"

  immutable_tags_enabled = true
  cleanup_policy_dry_run = false
  delete_older_than      = "2592000s"
  delete_untagged_only   = true
  keep_most_recent_count = 10

  additional_iam_bindings = [
    {
      role   = "roles/artifactregistry.reader"
      member = module.app1_service_account.member
    }
  ]

  common_labels = var.common_labels

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                      | Description                                                                            | Type           | Required |
|---------------------------|------------------------------------------------------------------------------------------|----------------|----------|
| `repository_id`           | The name of the Artifact Registry repository                                            | `string`       | Yes      |
| `location`                | The location where the repository is created                                            | `string`       | Yes      |
| `format`                  | The format of packages stored in the repository, for example DOCKER, MAVEN, NPM, PYTHON | `string`       | Optional |
| `mode`                    | The mode of the repository (STANDARD_REPOSITORY\|REMOTE_REPOSITORY\|VIRTUAL_REPOSITORY) | `string`       | Optional |
| `description`             | A short description of what the repository holds                                        | `string`       | Optional |
| `encryption_kms_key_id`   | The KMS key id used for the CMEK encryption of the repository                            | `string`       | Optional |
| `immutable_tags_enabled`  | Whether image tags are prevented from being overwritten                                 | `bool`         | Optional |
| `cleanup_policy_dry_run`  | Whether the cleanup policies only report what they would delete (default `true`)        | `bool`         | Optional |
| `delete_older_than`       | Deletes images older than this duration in seconds, for example 2592000s for 30 days    | `string`       | Optional |
| `delete_untagged_only`    | Whether the delete policy only applies to untagged images                               | `bool`         | Optional |
| `keep_most_recent_count`  | The number of most recent images kept regardless of the delete policy                   | `number`       | Optional |
| `additional_iam_bindings` | Additional IAM bindings to apply to the repository                                      | `list(object)` | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                                  | `map(string)`  | Optional |

## Outputs

| Name             | Description                                            |
|------------------|--------------------------------------------------------|
| `id`             | The full ID of the Artifact Registry repository        |
| `name`           | The name of the Artifact Registry repository           |
| `location`       | The location of the Artifact Registry repository       |
| `repository_url` | The base URL images are pushed to and pulled from      |

## Notes

- `cleanup_policy_dry_run` defaults to `true` so that a new policy reports what it would delete before anything is removed. Set it to `false` once you are happy with the reported results.
- When `encryption_kms_key_id` is set, the Artifact Registry service account of the project needs `roles/cloudkms.cryptoKeyEncrypterDecrypter` on the key before the repository is created.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/artifact_registry`):

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
- Proper IAM permissions for creating Artifact Registry repositories and IAM role bindings
- Google Service APIs `artifactregistry.googleapis.com` and `cloudkms.googleapis.com (optional)` should be enabled
---
