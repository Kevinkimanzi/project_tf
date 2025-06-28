variable "db_cluster_name" {
  description = "Name of the database cluster"
  type        = string
  default     = "webapp-mysql-cluster"
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8"
}

variable "db_size" {
  description = "Database instance size"
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "node_count" {
  description = "Number of database nodes"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "VPC ID for private networking"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for firewall rules"
  type        = string
}

variable "databases" {
  description = "Map of databases to create"
  type = map(object({
    database_name = string
    username      = string
  }))
  default = {
    app1 = {
      database_name = "webapp1"
      username      = "appuser1"
    }
    app2 = {
      database_name = "webapp2"
      username      = "appuser2"
    }
  }
}

variable "allowed_droplet_ids" {
  description = "List of droplet IDs allowed to access database"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for the database"
  type        = list(string)
  default     = ["production", "mysql"]
}