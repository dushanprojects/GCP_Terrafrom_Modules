# Secret Manager Module

This Terraform module provisions a **Google Secret Manager secret** using a shared module (`../../modules/secret_manager`). You can create a secret with automatic or user managed replication, encrypt it with a customer managed KMS key, set a rotation notification period, load an initial value, and grant read access to the application service accounts that need it. Please refer to the example usage shown below:

```hcl
# Creating the database password secret for Application 1
module "app1_db_password" {
  source = "../../modules/secret_manager"

  secret_id = "dev-app1-db-password"

  # Leave initial_version_enabled false when the value is added by an operator
  # or a pipeline instead of Terraform
  initial_version_enabled = true
  secret_data             = random_password.app1_db_user.result

  accessors = [
    module.app1_service_account.member
  ]

  # Rotation notifications need a Pub/Sub topic
  rotation_period     = "7776000s"
  notification_topics = [google_pubsub_topic.secret_rotation.id]

  common_labels = var.common_labels

  depends_on = [module.enable_google_service_apis]
}
```

## Inputs

| Name                      | Description                                                                                    | Type           | Required |
|---------------------------|--------------------------------------------------------------------------------------------------|----------------|----------|
| `secret_id`               | The name of the secret                                                                          | `string`       | Yes      |
| `initial_version_enabled` | Whether an initial secret version is created from `secret_data` (default `false`)               | `bool`         | Optional |
| `secret_data`             | The initial value of the secret. Only used when `initial_version_enabled` is true               | `string`       | Optional |
| `replica_locations`       | List of regions the secret is replicated to. Leave empty to let Google manage the replication   | `list(string)` | Optional |
| `encryption_kms_key_id`   | The KMS key id used for the CMEK encryption of the secret                                       | `string`       | Optional |
| `rotation_period`         | The interval the rotation notification is sent on, for example 7776000s for 90 days             | `string`       | Optional |
| `next_rotation_time`      | The timestamp of the next rotation notification in RFC 3339 format                              | `string`       | Optional |
| `notification_topics`     | List of Pub/Sub topic names that receive the rotation and version events of the secret          | `list(string)` | Optional |
| `accessors`               | List of members allowed to read the secret value                                                | `list(string)` | Optional |
| `additional_iam_bindings` | Additional IAM bindings to apply to the secret                                                  | `list(object)` | Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                                          | `map(string)`  | Optional |

## Outputs

| Name         | Description                                                                    |
|--------------|--------------------------------------------------------------------------------|
| `id`         | The full ID of the secret with format projects/{{project}}/secrets/{{secret_id}} |
| `secret_id`  | The name of the secret                                                         |
| `name`       | The fully qualified name of the secret                                         |
| `version_id` | The full ID of the initial secret version, or null when no initial value was set |

## Notes

- `secret_data` is only written when `initial_version_enabled` is set to `true`. The flag is separate from the value because Terraform has to know how many versions it creates before the value itself is known, for example when the value comes from a generated password.
- A value passed through `secret_data` is stored in the Terraform state. For values that must never reach the state, create the secret without `secret_data` and add the version with `gcloud secrets versions add` or from a pipeline.
- `rotation_period` needs at least one Pub/Sub topic in `notification_topics`, because Google sends the rotation notification to a topic. The Secret Manager service account of the project also needs `roles/pubsub.publisher` on that topic.
- `rotation_period` only sends a rotation notification. The new secret value still has to be created by your own process.
- User managed replication cannot be changed to automatic replication later, so choose the replication before the secret is created.

## Tests

This module has its own tests, written with the Terraform test framework. The tests sit in the `tests` directory of the module and use a mocked provider, so they need no GCP credentials, they make no API calls and they create nothing in GCP.

Run them from this directory (`modules/secret_manager`):

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
- Proper IAM permissions for creating secrets and IAM role bindings
- Google Service APIs `secretmanager.googleapis.com` and `cloudkms.googleapis.com (optional)` should be enabled
---
