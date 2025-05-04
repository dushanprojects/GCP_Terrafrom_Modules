
# KMS Key Ring & Cryptop Keys Example

This example demonstrates how to create a KMS Key Ring and associated Crypto Keys on Google Cloud Platform using Terraform. It defines resource names, locations, optional IAM role bindings, and labels appropriate for typical production or staging environments.

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


## Outputs

| Name                | Description                       | 
|---------------------|-----------------------------------|
| `kms_key_ring_name` | The name of the KMS key ring      |
| `kms_key_ring_id`   | The full ID of the KMS key ring   |
| `kms_key_name`      | The name of the KMS crypto key    |
| `kms_key_id`        | The full ID of the KMS crypto key |

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