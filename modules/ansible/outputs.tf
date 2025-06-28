output "inventory_file" {
  description = "Path to Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}

output "ansible_directory" {
  description = "Ansible working directory"
  value       = var.ansible_dir
}