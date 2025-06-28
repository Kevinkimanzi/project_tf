terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_loadbalancer" "web" {
  name   = var.lb_name
  region = var.region
  size   = var.lb_size
  
  vpc_uuid = var.vpc_id
  
  # Only HTTP forwarding rule for now
  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 80
  }
  
  # Health check
  healthcheck {
    protocol                 = "http"
    port                     = 80
    path                     = "/"
    check_interval_seconds   = 10
    response_timeout_seconds = 5
    healthy_threshold        = 3
    unhealthy_threshold      = 3
  }
  
  # Target droplets
  droplet_ids = var.droplet_ids
}