output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC with format projects/{{project}}/global/networks/{{name}}"
}

output "private_services_range_name" {
  value       = google_compute_global_address.private_services_range.name
  description = "The name of the IP range reserved for Google managed services"
}

output "redis_instance_name" {
  value       = module.app1_redis.name
  description = "The name of the Redis instance"
}

output "redis_host" {
  value       = module.app1_redis.host
  description = "The IP address clients connect to"
}

output "redis_port" {
  value       = module.app1_redis.port
  description = "The port clients connect to"
}

output "redis_auth_secret_id" {
  value       = module.app1_redis_auth_string.secret_id
  description = "The name of the secret holding the auth string of the cache"
}
