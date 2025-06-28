resource "digitalocean_ssh_key" "main" {
  name       = "terraform-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "network" {
  source = "./modules/network"
  
  #vpc_name    = var.vpc_name
  region      = var.region
  droplet_ids = module.droplets.droplet_ids

 #depends_on = [module.droplets]
}

module "droplets" {
  source = "./modules/droplets"
  
  droplet_names   = var.droplet_names
  region          = var.region
  vpc_id          = module.network.vpc_id
  ssh_key_id      = digitalocean_ssh_key.main.fingerprint
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  
  lb_name         = "web-lb"
  region          = var.region
  vpc_id          = module.network.vpc_id
  droplet_ids     = module.droplets.droplet_ids
  redirect_https  = var.enable_https_redirect
}


module "database" {
  source = "./modules/database"
  
  
  db_cluster_name     = "webapp-mysql-cluster"
  region              = var.region
  vpc_id              = module.network.vpc_id
  vpc_cidr            = module.network.vpc_cidr
  allowed_droplet_ids = module.droplets.droplet_ids
  
  
  databases = var.app_databases
}


module "ansible" {
  source = "./modules/ansible"
  
  droplets = [
    for name, droplet in module.droplets.droplet_details : {
      id           = droplet.id
      name         = name
      ipv4_address = droplet.ipv4_address
    }
  ]
  
  domain_name     = var.domain_name
  ansible_dir     = "./ansible"
  run_playbook    = var.run_ansible
}