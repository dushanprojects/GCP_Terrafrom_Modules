# KMS Key Ring Module

This Terraform module provisions a **Google KMS Key Ring** for reuse with KMS keys using a shared module (`../../modules/kms_key_ring`). For example, you can create a common key ring for storage bucket encryption and reuse it when creating separate KMS keys for each application. This module relies on inputs such as the name and labels. Please refer to the example usage shown below:

## Module Usage

```hcl
# Creating a common KMS key ring for GCS
module "gcs_kms_key_ring" {
  source = "../../modules/kms_key_ring"

  name          = "gcs-encryption"
  location      = "US"
  common_labels = var.common_labels
  depends_on    = [ module.enable_google_service_apis ]
}
```

## Inputs

| Name              | Description                                            | Type          | Required |
|-------------------|--------------------------------------------------------|---------------|----------|
| `name`            | The name of the KMS Key Ring                           | `string`      | Yes      |
| `location`        | The location for the KeyRing                           | `string`      | Yes      |
| `common_labels`   | A map of key-value pairs to tag resources consistently | `map(string)` | Optional |

## Outputs

| Name    | Description                   | 
|---------|-------------------------------|
| `id`    | The ID of the KMS Key Ring    |
| `name`  | The name of the KMS key ring  |


## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating GKE KMS Key Ring
- Google Service API `cloudkms.googleapis.com` should be enabled
---
