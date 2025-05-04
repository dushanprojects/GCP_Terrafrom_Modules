
# Cloud Storage Bucket with Encryption Example

This example demonstrates how to create a storage bucket with customer managed KMS encyption in Google Cloud Platform using Terraform. This example has dependancy with KMS key ring and KMS key modeuls. The storage bucket defines resource name, storage class, bucket access logging, versioning, locations, optional lyfecycle rules and labels suitable for common production or staging environments.

## Inputs (KMS Key Ring)

| Name            | Description                                            | Type           | Required |
|-----------------|--------------------------------------------------------|----------------|----------|
| `name`          | The name of the KMS Key Ring                           | `string`       | Yes      |
| `location`      | The location for the KeyRing                           | `string`       | Yes      |
| `common_labels` | A map of key-value pairs to tag resources consistently | `map(string)`  | Optional |


## Inputs (KMS Cryptop Keys)

| Name                     | Description                                                                      | Type          | Required |
|--------------------------|----------------------------------------------------------------------------------|---------------|----------|
| `name`                   | List of KMS crypto key names                                                     | `list(string)`| Yes      |
| `rotation_period`        | Interval to auto-rotate and set a new primary CryptoKeyVersion (default 30 days) | `string`      | Optional |
| `additional_iam_bindings`| Optional IAM bindings to apply to KMS key                                        | `list(object)`| Optional |
| `common_labels`          | A map of key-value pairs to tag resources consistently                           | `map(string)` | Yes      |


## Inputs (Storage Bucket)

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

| Name                | Description                                                  | 
|---------------------|--------------------------------------------------------------|
| `kms_key_ring_name` | The name of the KMS key ring                                 |
| `kms_key_ring_id`   | The full ID of the KMS key ring                              |
| `kms_key_name`      | The name of the KMS crypto key                               |
| `kms_key_id`        | The full ID of the KMS crypto key                            |
| `bucket_url`        | The base URL of the bucket, in the format gs://<bucket-name> |
| `bucket_name`       | Name of the storage bucket                                   |
| `bucket_self_link`  | The URI of the created resource                              |

# Provisioning Instructions

## Prerequisites
Before deploying this Cloud Function, ensure you have the following configured:

 - Set the `region` and `project_id` variables in the `variables.tf` file to match your Google Cloud environment.

These values are required to properly target the correct project and region for resource discovery.

## Terraform commands
To deploy this example, run the following commands from within this directory:
- `terraform init` – Initializes the working directory and downloads necessary providers.
- `terraform plan` – Previews the changes Terraform will make to your infrastructure.
- `terraform apply` – Applies the planned infrastructure changes.
- `terraform destroy` – Tears down all resources created by this configuration.