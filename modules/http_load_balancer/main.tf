# The public IP address the load balancer serves on
resource "google_compute_global_address" "this" {
  name = "${var.name}-address"
}

# Google managed certificate for the listed domains
resource "google_compute_managed_ssl_certificate" "this" {
  count = var.ssl_certificate_id == null ? 1 : 0

  name = "${var.name}-certificate"

  managed {
    domains = var.domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Connects the load balancer to the Cloud Run service
resource "google_compute_region_network_endpoint_group" "serverless" {
  name                  = "${var.name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_backend_service" "this" {
  name                  = "${var.name}-backend"
  description           = var.description
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = var.security_policy_id
  enable_cdn            = var.cdn_enabled
  timeout_sec           = var.backend_timeout_sec

  backend {
    group = google_compute_region_network_endpoint_group.serverless.id
  }

  log_config {
    enable      = var.request_logging_enabled
    sample_rate = var.request_logging_sample_rate
  }

  dynamic "cdn_policy" {
    for_each = var.cdn_enabled ? [1] : []
    content {
      cache_mode        = var.cdn_cache_mode
      default_ttl       = var.cdn_default_ttl
      client_ttl        = var.cdn_default_ttl
      max_ttl           = var.cdn_max_ttl
      negative_caching  = true
      serve_while_stale = 86400
    }
  }
}

resource "google_compute_url_map" "this" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.this.id
}

resource "google_compute_target_https_proxy" "this" {
  name             = "${var.name}-https-proxy"
  url_map          = google_compute_url_map.this.id
  ssl_certificates = [var.ssl_certificate_id != null ? var.ssl_certificate_id : google_compute_managed_ssl_certificate.this[0].id]
  ssl_policy       = var.ssl_policy_id
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.name}-https-rule"
  target                = google_compute_target_https_proxy.this.id
  ip_address            = google_compute_global_address.this.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# Sends the plain HTTP traffic to the HTTPS listener
resource "google_compute_url_map" "http_redirect" {
  count = var.http_redirect_enabled ? 1 : 0

  name = "${var.name}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_redirect" {
  count = var.http_redirect_enabled ? 1 : 0

  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.http_redirect[0].id
}

resource "google_compute_global_forwarding_rule" "http" {
  count = var.http_redirect_enabled ? 1 : 0

  name                  = "${var.name}-http-rule"
  target                = google_compute_target_http_proxy.http_redirect[0].id
  ip_address            = google_compute_global_address.this.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
