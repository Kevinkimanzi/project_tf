output "lb_id" {
  description = "ID of the load balancer"
  value       = digitalocean_loadbalancer.web.id
}

output "lb_ip" {
  description = "Public IP of the load balancer"
  value       = digitalocean_loadbalancer.web.ip
}

output "lb_status" {
  description = "Status of the load balancer"
  value       = digitalocean_loadbalancer.web.status
}