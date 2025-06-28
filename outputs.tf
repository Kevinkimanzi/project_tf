output "droplet_ips" {
  value       = module.droplets.droplet_ips
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "load_balancer_ip" {
  description = "Load balancer public IP"
  value       = module.loadbalancer.lb_ip
}

output "load_balancer_status" {
  description = "Load balancer status"
  value       = module.loadbalancer.lb_status
}

output "database_host" {
  description = "Database host (private)"
  value       = module.database.database_host
}

output "database_connections" {
  description = "Database connection details for each app"
  value       = module.database.database_connection_strings
  sensitive   = true
}
