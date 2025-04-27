# Enable GCP APIs Module

This Terraform module enables one or more Google Cloud APIs (services) for a given project.

It uses the `google_project_service` resource to activate required services dynamically based on the provided list.

## Module Usage

```hcl
module "enable_google_service_apis" {
  source     = "../../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
```

## Inputs

| Name          | Description                                                | Type           | Required |
|---------------|------------------------------------------------------------|----------------|----------|
| `project_id`  | The ID of the GCP project where resources will be created. | `string`       | Yes      |
| `apis`        | A list of API service names to enable.                     | `list(string)` | Yes      |


## Outputs
None.

## Requirements

- [Terraform](https://www.terraform.io/) >= 1.0
- GCP project with billing enabled
- Proper IAM permissions for creating GKE clusters and networking resources
- A pre-created custom VPC or shared default VPC with the required subnet(s)


## Notes

## Purpose
This module enables multiple GCP APIs (`services`) in a project, based on a list you provide.

## Behavior
- Uses `for_each` to create one `google_project_service` resource per API.
- Makes it easy to manage many APIs at once without repeating code.

## Important Tips
- **Enabling an API can take time** — Terraform may need to wait for the service to be fully available before using it (e.g., creating a GKE cluster right after enabling Kubernetes API).
- **Use `depends_on`** if your resources need to wait until the APIs are fully enabled.
- **Idempotent** — Terraform won’t try to re-enable already active APIs unnecessarily.
- **API Naming** — Ensure API names (like `compute.googleapis.com`) are correct. Incorrect names will cause Terraform errors.

## Typical Use Case
Enable required APIs before creating resources like:
- GKE clusters
- Cloud Storage buckets
- Pub/Sub topics
- IAM policies

## Example Common APIs
- `compute.googleapis.com` — Compute Engine
- `storage.googleapis.com` — Cloud Storage
- `iam.googleapis.com` — Identity and Access Management
- `container.googleapis.com` — Kubernetes Engine
- `cloudresourcemanager.googleapis.com` — Cloud Resource Manager

---