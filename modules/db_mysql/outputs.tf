output "id" {
  value       = google_sql_database_instance.mysql.id
  description = "The ID of the DB instance"
}

output "name" {
  value       = google_sql_database_instance.mysql.name
  description = "The name of the DB instance"
}

output "self_link" {
  value       = google_sql_database_instance.mysql.self_link
  description = "The URI of the created resource"
}

output "connection_name" {
  value       = google_sql_database_instance.mysql.connection_name
  description = "The connection name of the instance, used by the Cloud SQL Auth Proxy and connectors"
}

output "private_ip_address" {
  value       = google_sql_database_instance.mysql.private_ip_address
  description = "The first private IPv4 address assigned to the instance"
}

output "public_ip_address" {
  value       = google_sql_database_instance.mysql.public_ip_address
  description = "The first public IPv4 address assigned to the instance"
}

output "server_ca_cert" {
  value       = google_sql_database_instance.mysql.server_ca_cert
  sensitive   = true
  description = "The CA certificate information used to connect to the instance over SSL"
}

output "database_names" {
  value       = [for db in google_sql_database.databases : db.name]
  description = "The names of the databases created on the instance"
}
