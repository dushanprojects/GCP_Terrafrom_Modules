# KMS Key Ring Module

This Terraform module provisions a **Google Storage Bucket** using a shared module (`../../modules/storage_bucket`). You can create a storage bucket with or without encryption, enable versioning, access logs, define multiple lifecycle rules, and more. The configuration includes resource naming, storage class, access logging, versioning, location, optional lifecycle rules, and labels suitable for common production or staging environments. Please refer to the example usage shown below:



## Module Usage

```hcl
# Creating a storage bucket - simple version
module "gcs" {
  source = "../../modules/storage_bucket"

  name                     = "dev-app1-resources-bucket"
  location                 = var.region
  storage_class            = "STANDARD"
  common_labels            = var.common_labels

  depends_on = [
    module.enable_google_service_apis,
  ]
}
```

## Inputs

| Name                      | Description                                                                   | Type          | Required |
|---------------------------|-------------------------------------------------------------------------------|---------------|----------|
| `name`                    | The name of the KMS Key Ring                                                  | `string`      | Yes      |
| `location`                | The location for the KeyRing                                                  | `string`      | Yes      |
| `public_access_prevention`| Prevents public access to a bucket (inherited|enforced)                       | `string`      | Optional |
| `storage_class`           | The Storage Class of the new bucket                                           | `string`      | Optional |
| `force_destroy_enabled`   | When deleting a bucket, this boolean option will delete all contained objects | `bool`        | Optional |
| `log_bucket_name`         | The bucket that will receive log objects                                      | `string`      | Optional |
| `versioning_enabled`      | Bucket versioning enabled|disabled                                            | `bool`        | Optional |
| `encryption_kms_key_id`   | The bucket's encryption KMS key id                                            | `string`      | Optional |
| `lifecycle_rules`         | List of lifecycle rules for the bucket                                        | `list(object)`| Optional |
| `common_labels`           | A map of key-value pairs to tag resources consistently                        | `map(string)` | Optional |


## Outputs

| Name        | Description                                                  | 
|-------------|--------------------------------------------------------------|
| `url`       | The base URL of the bucket, in the format gs://<bucket-name> |
| `name`      | Name of the storage bucket                                   |
| `self_link` | The URI of the created resource                              |


## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Ensure proper IAM permissions for creating a GKE KMS Key Ring, KMS Key, Storage Bucket, and associated IAM role bindings.
- Google Service APIs `storage-component.googleapis.com` and `cloudkms.googleapis.com (optional)` should be enabled
---
