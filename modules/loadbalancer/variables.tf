variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
  default     = "web-lb"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "lb_size" {
  description = "Size of the load balancer"
  type        = string
  default     = "lb-small"
}

variable "vpc_id" {
  description = "VPC ID for the load balancer"
  type        = string
}

variable "droplet_ids" {
  description = "List of droplet IDs to load balance"
  type        = list(string)
}

variable "redirect_https" {
  description = "Redirect HTTP traffic to HTTPS"
  type        = bool
  default     = false
}