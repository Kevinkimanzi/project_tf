output "vpc_id" {
  description = "ID of the VPC"
  value       = digitalocean_vpc.main.id
}

output "firewall_id" {
  description = "ID of the firewall"
  value       = length(digitalocean_firewall.web) > 0 ? digitalocean_firewall.web[0].id : null
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = digitalocean_vpc.main.ip_range
}