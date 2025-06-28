#!/bin/bash

# Simple Infrastructure Deployment Script

echo "Starting Infrastructure Deployment..."

# Terraform Operations
echo "Terraform init..."
terraform init

echo "Terraform plan..."
terraform plan

echo "Terraform apply..."
terraform apply -auto-approve

# Wait for infrastructure to be ready
echo "⏳ Waiting 30 seconds for infrastructure to be ready..."
sleep 30

# Run Ansible
echo "Running Ansible configuration..."
cd ansible
ansible-playbook -i inventory.ini setup.yml
cd ..


echo "Deployment Complete!"
echo ""
echo "Your infrastructure:"
echo "Load Balancer: http://$(terraform output -raw load_balancer_ip)"
echo "Droplet IPs: $(terraform output -json droplet_ips | jq -r '.[]' | tr '\n' ' ')"
echo ""
echo "Next steps:"
echo "1. Test: curl http://$(terraform output -raw load_balancer_ip)"
echo "2. SSH: ssh root@<droplet_ip>"
echo "3. Add files to /root/api/"