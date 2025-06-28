terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "create_ansible_dir" {
  content  = ""
  filename = "${var.ansible_dir}/.keep"
}

resource "local_file" "create_templates_dir" {
  content  = ""
  filename = "${var.ansible_dir}/templates/.keep"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    droplets = var.droplets
  })
  filename = "${var.ansible_dir}/inventory.ini"
}

# Generate Ansible config
resource "local_file" "ansible_config" {
  content = templatefile("${path.module}/templates/ansible.cfg.tpl", {
    ssh_private_key = var.ssh_private_key_path
  })
  filename = "${var.ansible_dir}/ansible.cfg"
}

# Copy playbook
resource "local_file" "setup_playbook" {
  content = templatefile("${path.module}/playbooks/setup.yml", {})
  filename = "${var.ansible_dir}/setup.yml"
}

# Copy Apache config template
resource "local_file" "apache_template" {
  content = templatefile("${path.module}/templates/apache.conf.j2", {})
  filename = "${var.ansible_dir}/templates/apache.conf.j2"
}

# Run Ansible (optional)
resource "null_resource" "run_ansible" {
  count = var.run_playbook ? 1 : 0
  
  triggers = {
    droplet_ids = join(",", [for d in var.droplets : d.id])
  }

  provisioner "local-exec" {
    command = <<-EOF
      cd ${var.ansible_dir}
      ansible-playbook -i inventory.ini setup.yml
    EOF
  }

  depends_on = [
    local_file.ansible_inventory,
    local_file.ansible_config,
    local_file.setup_playbook,
    local_file.apache_template
  ]
}