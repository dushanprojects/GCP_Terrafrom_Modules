output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC with format projects/{{project}}/global/networks/{{name}}"
}

output "private_services_range_name" {
  value       = google_compute_global_address.private_services_range.name
  description = "The name of the IP range reserved for Google managed services"
}

output "mysql_instance_name" {
  value       = module.mysql.name
  description = "The name of the DB instance"
}

output "mysql_connection_name" {
  value       = module.mysql.connection_name
  description = "The connection name of the instance, used by the Cloud SQL Auth Proxy and connectors"
}

output "mysql_private_ip_address" {
  value       = module.mysql.private_ip_address
  description = "The first private IPv4 address assigned to the instance"
}

output "mysql_self_link" {
  value       = module.mysql.self_link
  description = "The URI of the created resource."
}

output "mysql_database_names" {
  value       = module.mysql.database_names
  description = "The names of the databases created on the instance"
}

output "app1_db_user_password" {
  value       = random_password.app1_db_user.result
  sensitive   = true
  description = "The generated password of the app1 database user. Read it with: terraform output -raw app1_db_user_password"
}
