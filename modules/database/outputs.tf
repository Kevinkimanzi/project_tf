output "database_cluster_id" {
  description = "Database cluster ID"
  value       = digitalocean_database_cluster.mysql.id
}

output "database_host" {
  description = "Database host (private)"
  value       = digitalocean_database_cluster.mysql.private_host
}

output "database_port" {
  description = "Database port"
  value       = digitalocean_database_cluster.mysql.port
}

output "database_uri" {
  description = "Database connection URI"
  value       = digitalocean_database_cluster.mysql.private_uri
  sensitive   = true
}

output "databases" {
  description = "Created databases"
  value = {
    for key, db in digitalocean_database_db.app_databases : key => {
      name = db.name
      id   = db.id
    }
  }
}

output "database_users" {
  description = "Database users and their passwords"
  value = {
    for key, user in digitalocean_database_user.app_users : key => {
      username = user.name
      password = user.password
    }
  }
  sensitive = true
}

output "database_connection_strings" {
  description = "Connection details for each database"
  value = {
    for key, db in digitalocean_database_db.app_databases : key => {
      host     = digitalocean_database_cluster.mysql.private_host
      port     = digitalocean_database_cluster.mysql.port
      database = db.name
      username = digitalocean_database_user.app_users[key].name
      password = digitalocean_database_user.app_users[key].password
    }
  }
  sensitive = true
}