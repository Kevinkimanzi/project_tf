output "droplet_ids" {
  description = "IDs of created droplets"
  value       = [for droplet in digitalocean_droplet.web : droplet.id]
}

output "droplet_ips" {
  description = "Public IPs of droplets"
  value       = [for droplet in digitalocean_droplet.web : droplet.ipv4_address]
}

output "droplet_details" {
  description = "Complete droplet details"
  value = {
    for key, droplet in digitalocean_droplet.web : key => {
      id           = droplet.id
      name         = droplet.name
      ipv4_address = droplet.ipv4_address
    }
  }
}