# Service Account Module

This Terraform module provisions a **Google Service Account** using a shared module (`../../modules/service_account`). You can create a service account for an application or a pipeline, grant it project level roles, allow a Kubernetes service account to use it through Workload Identity, and allow other members to create access tokens for it. This module relies on inputs such as the account id, display name, project roles and impersonation members. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating a service account for Application 1
module "app1_service_account" {
  source = "../../modules/service_account"

  project_id   = var.project_id
  account_id   = "dev-app1-run"
  display_name = "Development Application 1 Cloud Run service account"
  description  = "Runtime identity of the Application 1 Cloud Run service"

  project_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/logging.logWriter"
  ]

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                      | Description                                                                                     | Type           | Required |
|---------------------------|-------------------------------------------------------------------------------------------------|----------------|----------|
| `project_id`              | Google Project ID the service account is created in                                             | `string`       | Yes      |
| `account_id`              | The account id of the service account, used as the first part of the email address              | `string`       | Yes      |
| `display_name`            | The display name of the service account                                                         | `string`       | Optional |
| `description`             | A short description of what the service account is used for                                     | `string`       | Optional |
| `project_roles`           | List of project level roles granted to the service account                                      | `list(string)` | Optional |
| `workload_identity_users` | List of members allowed to use this service account through Workload Identity                   | `list(string)` | Optional |
| `token_creators`          | List of members allowed to create access tokens for this service account                        | `list(string)` | Optional |

## Outputs

| Name        | Description                                                    |
|-------------|----------------------------------------------------------------|
| `id`        | The full ID of the service account                             |
| `name`      | The fully qualified name of the service account                |
| `email`     | The email address of the service account                       |
| `member`    | The service account in the format expected by IAM bindings     |
| `unique_id` | The unique id of the service account                           |

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/service_account`):

```
terraform init -backend=false
terraform test
```

The `init` is needed even though the provider is mocked, because Terraform reads the provider schema to check the resource arguments. Useful options while working on the module:

```
terraform test -verbose                        # show the plan behind every test case
terraform test -filter=tests/bindings.tftest.hcl   # run a single test file
```

A failing test prints the message written on the assertion, so the output says what the module should have done rather than only which line failed.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating service accounts and granting project level roles
- Google Service API `iam.googleapis.com` should be enabled
---
