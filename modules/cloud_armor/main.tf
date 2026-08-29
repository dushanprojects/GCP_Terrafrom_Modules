resource "google_compute_security_policy" "this" {
  name        = var.name
  description = var.description
  type        = var.type

  # Protects against layer 7 attacks such as application level floods
  dynamic "adaptive_protection_config" {
    for_each = var.adaptive_protection_enabled ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = true
        rule_visibility = var.adaptive_protection_rule_visibility
      }
    }
  }

  # Blocks the listed IP ranges
  dynamic "rule" {
    for_each = { for x, range in var.denied_ip_ranges : tostring(x) => range }
    content {
      action      = "deny(403)"
      priority    = 1000 + tonumber(rule.key)
      description = "Denies traffic from ${rule.value}"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [rule.value]
        }
      }
    }
  }

  # Allows only the listed IP ranges when the default action is deny
  dynamic "rule" {
    for_each = { for x, range in var.allowed_ip_ranges : tostring(x) => range }
    content {
      action      = "allow"
      priority    = 2000 + tonumber(rule.key)
      description = "Allows traffic from ${rule.value}"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [rule.value]
        }
      }
    }
  }

  # Preconfigured WAF rules such as sqli, xss and lfi
  dynamic "rule" {
    for_each = { for x, waf_rule in var.waf_rules : tostring(x) => waf_rule }
    content {
      action      = rule.value.action
      priority    = 3000 + tonumber(rule.key)
      description = "Preconfigured WAF rule ${rule.value.expression}"
      match {
        expr {
          expression = rule.value.expression
        }
      }
      preview = rule.value.preview
    }
  }

  # Limits how many requests a single client can send
  dynamic "rule" {
    for_each = var.rate_limit_threshold_count != null ? [1] : []
    content {
      action      = "rate_based_ban"
      priority    = 4000
      description = "Limits the number of requests received from a single client"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = ["*"]
        }
      }
      rate_limit_options {
        conform_action = "allow"
        exceed_action  = "deny(429)"
        enforce_on_key = var.rate_limit_enforce_on_key
        rate_limit_threshold {
          count        = var.rate_limit_threshold_count
          interval_sec = var.rate_limit_interval_sec
        }
        ban_duration_sec = var.rate_limit_ban_duration_sec
      }
    }
  }

  # The default rule is applied when no other rule matches
  rule {
    action      = var.default_rule_action
    priority    = 2147483647
    description = "Default rule of the security policy"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
