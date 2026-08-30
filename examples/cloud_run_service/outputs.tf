output "service_account_email" {
  value       = module.app1_service_account.email
  description = "The email address of the runtime service account"
}

output "artifact_registry_url" {
  value       = module.app1_artifact_registry.repository_url
  description = "The base URL images are pushed to and pulled from"
}

output "api_key_secret_id" {
  value       = module.app1_api_key.secret_id
  description = "The name of the API key secret"
}

output "cloud_run_service_name" {
  value       = module.app1_cloud_run.name
  description = "The name of the Cloud Run service"
}

output "cloud_run_uri" {
  value       = module.app1_cloud_run.uri
  description = "The direct URL of the Cloud Run service"
}

output "load_balancer_ip_address" {
  value       = module.app1_load_balancer.ip_address
  description = "The public IP address of the load balancer. Point the DNS records of the domains at this address"
}

output "security_policy_name" {
  value       = module.app1_cloud_armor.name
  description = "The name of the Cloud Armor security policy"
}
