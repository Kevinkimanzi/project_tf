terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# resource "digitalocean_ssh_key" "default" {
#   name       = "terraform-key"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

resource "digitalocean_droplet" "web" {
  for_each = toset(var.droplet_names)
  
  name   = each.value
  image  = "ubuntu-22-04-x64"
  size   = "s-1vcpu-1gb"
  region = var.region
  
  vpc_uuid = var.vpc_id
  ssh_keys = [var.ssh_key_id]
  
  user_data = file("${path.module}/user_data.sh")
}