variable "droplet_count" {
  type    = number
  default = 2
}

variable "droplet_names" {
  type    = list(string)
  default = ["web-1", "web-2"]
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "enable_https_redirect" {
  description = "Enable HTTPS redirect on load balancer"
  type        = bool
  default     = false
}

variable "app_databases" {
  description = "Map of applications and their database configurations"
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

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "localhost"
}

variable "run_ansible" {
  description = "Run Ansible playbook automatically"
  type        = bool
  default     = false
}