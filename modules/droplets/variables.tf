variable "droplet_names" {
  description = "List of droplet names"
  type        = list(string)
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "vpc_id" {
  description = "VPC ID to place droplets in"
  type        = string
}

variable "ssh_key_id" {
  description = "SSH key fingerprint to use"
  type        = string
}