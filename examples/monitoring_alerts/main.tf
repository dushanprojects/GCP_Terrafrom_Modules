provider "google" {
  project = var.project_id
  region  = var.region
}

# Enabeling Service APIs
module "enable_google_service_apis" {
  source     = "../../modules/enable_services"
  project_id = var.project_id
  apis = [
    "monitoring.googleapis.com"
  ]
}

# Creating the uptime checks and the alerts of the platform
module "platform_monitoring" {
  source = "../../modules/monitoring_alerts"

  project_id = var.project_id

  notification_channels = [
    {
      display_name = "Platform team email"
      type         = "email"
      labels = {
        email_address = var.alert_email_address
      }
    }
  ]

  uptime_checks = [
    {
      display_name      = "Application 1 public endpoint"
      host              = var.monitored_host
      path              = "/healthz"
      period            = "60s"
      failing_locations = 2
    }
  ]

  metric_alerts = [
    {
      display_name       = "Application 1 server error rate is high"
      filter             = "metric.type=\"run.googleapis.com/request_count\" AND resource.type=\"cloud_run_revision\" AND metric.labels.response_code_class=\"5xx\""
      threshold_value    = 5
      duration           = "300s"
      per_series_aligner = "ALIGN_RATE"
      documentation      = "Application 1 is returning server errors. Check the logs of the latest Cloud Run revision, then check the load balancer backend health."
    },
    {
      display_name         = "Application 1 request latency is high"
      filter               = "metric.type=\"run.googleapis.com/request_latencies\" AND resource.type=\"cloud_run_revision\""
      threshold_value      = 2000
      duration             = "300s"
      per_series_aligner   = "ALIGN_PERCENTILE_95"
      cross_series_reducer = "REDUCE_MEAN"
      documentation        = "The 95th percentile request latency of Application 1 is above two seconds. Check the instance count and the database response times."
    },
    {
      display_name         = "MySQL instance CPU is high"
      filter               = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" AND resource.type=\"cloudsql_database\""
      threshold_value      = 0.8
      duration             = "600s"
      per_series_aligner   = "ALIGN_MEAN"
      cross_series_reducer = "REDUCE_MAX"
      documentation        = "The MySQL instance has been above 80 percent CPU for ten minutes. Check the slow query log before you resize the instance."
    },
    {
      display_name         = "MySQL instance disk is filling up"
      filter               = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\" AND resource.type=\"cloudsql_database\""
      threshold_value      = 0.85
      duration             = "600s"
      per_series_aligner   = "ALIGN_MEAN"
      cross_series_reducer = "REDUCE_MAX"
      documentation        = "The MySQL instance disk is above 85 percent full. Automatic disk growth is enabled but the growth limit should be reviewed."
    }
  ]

  common_labels = merge(var.common_labels, {
    environment = "development"
    appid       = "platform"
  })

  depends_on = [module.enable_google_service_apis]
}
