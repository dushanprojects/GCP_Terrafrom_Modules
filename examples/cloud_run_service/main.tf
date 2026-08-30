provider "google" {
  project = var.project_id
  region  = var.region
}

# Enabeling Service APIs
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com"
  ]
}

# Creating the runtime service account of the application
module "app1_service_account" {
  source = "../../modules/service_account"

  project_id   = var.project_id
  account_id   = "dev-app1-run"
  display_name = "Development Application 1 Cloud Run service account"
  description  = "Runtime identity of the Application 1 Cloud Run service"

  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent"
  ]

  depends_on = [module.enable_google_service_apis]
}

# Creating the container image repository of the application
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

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  depends_on = [module.enable_google_service_apis]
}

# Generating the application API key.
# In a real environment this value is created by the application team
resource "random_password" "app1_api_key" {
  length  = 32
  special = false
}

# Creating the API key secret the service reads at start up
module "app1_api_key" {
  source = "../../modules/secret_manager"

  secret_id               = "dev-app1-api-key"
  initial_version_enabled = true
  secret_data             = random_password.app1_api_key.result

  accessors = [
    module.app1_service_account.member
  ]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  depends_on = [module.enable_google_service_apis]
}

# Creating the Cloud Run service.
# The image below is the Google sample image, so the example can be applied
# before your own image has been pushed to the repository. Replace it with
# "${module.app1_artifact_registry.repository_url}/app1:TAG" once you have one
module "app1_cloud_run" {
  source = "../../modules/cloud_run"

  name                  = "dev-app1"
  location              = var.region
  image                 = "us-docker.pkg.dev/cloudrun/container/hello"
  service_account_email = module.app1_service_account.email

  # Only the load balancer is allowed to reach the service
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  invokers = ["allUsers"]

  cpu_limit               = "1"
  memory_limit            = "512Mi"
  min_instances           = 1
  max_instances           = 10
  max_concurrent_requests = 80

  environment_variables = {
    APP_ENVIRONMENT = "development"
  }

  secret_environment_variables = [
    {
      name      = "APP_API_KEY"
      secret_id = module.app1_api_key.secret_id
    }
  ]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "app1"
  })

  depends_on = [
    module.enable_google_service_apis,
    module.app1_api_key
  ]
}

# Creating the security policy applied to the public traffic
module "app1_cloud_armor" {
  source = "../../modules/cloud_armor"

  name        = "dev-app1-security-policy"
  description = "Protects the Application 1 load balancer"

  default_rule_action         = "allow"
  adaptive_protection_enabled = true

  waf_rules = [
    {
      expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      action     = "deny(403)"
    },
    {
      expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      action     = "deny(403)"
    },
    {
      expression = "evaluatePreconfiguredExpr('lfi-v33-stable')"
      action     = "deny(403)"
      preview    = true
    }
  ]

  rate_limit_threshold_count = 100
  rate_limit_interval_sec    = 60

  depends_on = [module.enable_google_service_apis]
}

# Creating the public load balancer in front of the service
module "app1_load_balancer" {
  source = "../../modules/http_load_balancer"

  name                   = "dev-app1"
  region                 = var.region
  cloud_run_service_name = module.app1_cloud_run.name
  domains                = var.domains
  description            = "Public entry point of Application 1"

  security_policy_id    = module.app1_cloud_armor.id
  http_redirect_enabled = true

  request_logging_enabled     = true
  request_logging_sample_rate = 1

  depends_on = [
    module.enable_google_service_apis,
    module.app1_cloud_run
  ]
}
