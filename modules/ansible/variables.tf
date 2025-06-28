variable "droplets" {
  description = "List of droplet objects"
  type = list(object({
    id             = string
    name           = string
    ipv4_address   = string
  }))
}

variable "domain_name" {
  description = "Domain name for Apache config"
  type        = string
  default     = "example.com"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ansible_dir" {
  description = "Directory for Ansible files"
  type        = string
  default     = "./ansible"
}

variable "run_playbook" {
  description = "Whether to run Ansible playbook automatically"
  type        = bool
  default     = false
}