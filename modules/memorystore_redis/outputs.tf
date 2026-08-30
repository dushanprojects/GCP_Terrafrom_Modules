output "id" {
  value       = google_redis_instance.this.id
  description = "The full ID of the Redis instance"
}

output "name" {
  value       = google_redis_instance.this.name
  description = "The name of the Redis instance"
}

output "host" {
  value       = google_redis_instance.this.host
  description = "The IP address clients connect to"
}

output "port" {
  value       = google_redis_instance.this.port
  description = "The port clients connect to"
}

output "current_location_id" {
  value       = google_redis_instance.this.current_location_id
  description = "The zone the primary node currently sits in"
}

output "auth_string" {
  value       = google_redis_instance.this.auth_string
  sensitive   = true
  description = "The auth string clients send before they can use the instance"
}
