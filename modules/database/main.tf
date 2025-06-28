terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# DigitalOcean Managed MySQL Database Cluster
resource "digitalocean_database_cluster" "mysql" {
  name       = var.db_cluster_name
  engine     = "mysql"
  version    = var.mysql_version
  size       = var.db_size
  region     = var.region
  node_count = var.node_count
  
  private_network_uuid = var.vpc_id
  
  tags = var.tags
}

# Create multiple databases within the cluster using for_each
resource "digitalocean_database_db" "app_databases" {
  for_each = var.databases
  
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = each.value.database_name
}

# Create multiple database users using for_each
resource "digitalocean_database_user" "app_users" {
  for_each = var.databases
  
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = each.value.username
}

# Database firewall (restrict access to web servers only)
resource "digitalocean_database_firewall" "mysql_firewall" {
  cluster_id = digitalocean_database_cluster.mysql.id

  # Allow access from web servers using for_each
  dynamic "rule" {
    for_each = var.allowed_droplet_ids
    content {
      type  = "droplet"
      value = rule.value
    }
  }

  # Allow access from VPC CIDR
  rule {
    type  = "ip_addr"
    value = var.vpc_cidr
  }
}