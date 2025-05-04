# KMS Key Ring Module

This Terraform module provisions a **Google KMS Key Ring** for reuse with KMS keys using a shared module (`../../modules/kms_key_ring`). For example, you can create a common key ring for storage bucket encryption and reuse it when creating separate KMS keys for each application. This module relies on inputs such as the name, additional IAM role binding and labels. Please refer to the example usage shown below:

## Module Usage

```hcl
data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

# Creating a KMS keys for application
module "gcs_kms_keys" {
  source = "../../modules/kms_keys"

  key_name      = "dev-app1-gcs"
  kms_ring_id   = module.gcs_kms_key_ring.id
  common_labels = var.common_labels
  additional_iam_bindings = [
    {
      role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
    }
  ]
  depends_on = [module.enable_google_service_apis, module.gcs_kms_key_ring]
}
```

## Inputs

| Name                     | Description                                                                      | Type          | Required |
|--------------------------|----------------------------------------------------------------------------------|---------------|----------|
| `name`                   | List of KMS crypto key names                                                     | `list(string)`| Yes      |
| `rotation_period`        | Interval to auto-rotate and set a new primary CryptoKeyVersion (default 30 days) | `string`      | Optional |
| `additional_iam_bindings`| Optional IAM bindings to apply to KMS key                                        | `list(object)`| Optional |
| `common_labels`          | A map of key-value pairs to tag resources consistently                           | `map(string)` | Yes      |


## Outputs

| Name   | Description                   | 
|--------|-------------------------------|
| `id`   | KMS crypto key name           |
| `name` | Full ID of the KMS crypto key |


## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating GKE KMS Crypto Keys
- Google Service API `cloudkms.googleapis.com` should be enabled
---
