# LAMP Stack Infrastructure with Load Balancer

**One-click deployment** of a complete LAMP (Linux, Apache, MySQL, PHP) stack on DigitalOcean with load balancing and database clustering.

## What You Get

- **2 Web Servers**: Ubuntu 22.04 + Apache + PHP 8.1
- **1 Load Balancer**: Traffic distribution between servers  
- **1 MySQL Cluster**: Managed database with 2 separate databases
- **1 VPC**: Private networking + firewall protection
- **SSL Ready**: Pre-configured for SSL certificates

---

## Prerequisites Setup

### Step 1: Install Required Tools

Install Terraform and Ansible

### Step 2: Get DigitalOcean API Token

1. **Login to DigitalOcean**: [https://cloud.digitalocean.com/](https://cloud.digitalocean.com/)
2. **Navigate to API**: Go to `API` → `Tokens/Keys` → `Generate New Token`
3. **Create token**: Name it `LAMP-Stack` and copy the token
4. **Set environment variable**:

```bash
# Replace 'your_actual_token_here' with your real token
export DIGITALOCEAN_TOKEN="dop_v1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Verify token is set
echo "Token set: ${DIGITALOCEAN_TOKEN:0:10}..."
```

**💡 Pro Tip**: Add the export command to your `~/.bashrc` or `~/.zshrc` for persistence:

```bash
echo 'export DIGITALOCEAN_TOKEN="your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

---

## Quick Deploy (One Command)

### Option 1: Automated Deployment

```bash
# Clone or download the project first, then:
cd project_tf

# Make deployment script executable
chmod +x deploy.sh

# Deploy everything (takes ~8 minutes)
./deploy.sh
```

### Option 2: Step-by-Step Deployment

```bash
# 1. Initialize Terraform
terraform init

# 2. Review deployment plan
terraform plan

# 3. Deploy infrastructure
terraform apply -auto-approve

# 4. Configure servers with Ansible
cd ansible
ansible-playbook -i inventory.ini setup.yml
cd ..

# 5. Display connection info
terraform output
```

---

## Access Your Infrastructure

### Get Your Endpoints

```bash
# View all connection details
terraform output

# Get load balancer IP only
terraform output -raw load_balancer_ip

# Get individual server IPs
terraform output -json droplet_ips | jq -r '.[]'

# Get database connection details
terraform output -json database_connections | jq '.'
```

### Get Database Credentials

```bash
# Display formatted database connection info
terraform output -json database_connections | jq -r '
  to_entries[] | 
  "\(.key):\n  Host: \(.value.host)\n  Database: \(.value.database)\n  Username: \(.value.username)\n  Password: \(.value.password)\n  Port: \(.value.port)\n"
'
```

### Test Database Connection

```bash
# Get database details
DB_HOST=$(terraform output -json database_connections | jq -r '.app1.host')
DB_USER=$(terraform output -json database_connections | jq -r '.app1.username') 
DB_PASS=$(terraform output -json database_connections | jq -r '.app1.password')
DB_NAME=$(terraform output -json database_connections | jq -r '.app1.database')

echo "Database Host: $DB_HOST"
echo "Database Name: $DB_NAME"
echo "Username: $DB_USER"

# Test connection from your local machine (if you have mysql client)
mysql -h $DB_HOST -P 25060 -u $DB_USER -p$DB_PASS $DB_NAME -e "SELECT 'Connection successful!' as status;"
```

### Test Database from Server

```bash
# SSH into server
ssh root@$SERVER1_IP

# Test database connection from server
mysql -h $DB_HOST -P 25060 -u $DB_USER -p$DB_PASS $DB_NAME << EOF
SHOW TABLES;
CREATE TABLE IF NOT EXISTS test_table (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
INSERT INTO test_table (message) VALUES ('Hello from LAMP stack!');
SELECT * FROM test_table;
EOF
```

### Test Your Application

```bash
# Get load balancer IP port is 80
LB_IP=$(terraform output -raw load_balancer_ip)

# Test main page
curl http://$LB_IP/80

# Test a specific port
curl http://$LB_IP/80

# Test with headers to see which server responds
curl -I http://$LB_IP/80
```

---

## 🔒 SSL Certificate Setup

### For Custom Domain

```bash
# 1. Point your domain to load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Point your domain DNS A record to: $LB_IP"

# 2. Get server IPs for SSL setup
SERVER1_IP=$(terraform output -json droplet_ips | jq -r '.[0]')
SERVER2_IP=$(terraform output -json droplet_ips | jq -r '.[1]')

# 3. Install SSL on first server
ssh root@$SERVER1_IP << 'EOF'
apt install -y certbot python3-certbot-apache
certbot --apache -d yourdomain.com --non-interactive --agree-tos --email your-email@example.com
systemctl reload apache2
EOF

# 4. Install SSL on second server  
ssh root@$SERVER2_IP << 'EOF'
apt install -y certbot python3-certbot-apache
certbot --apache -d yourdomain.com --non-interactive --agree-tos --email your-email@example.com
systemctl reload apache2
EOF

# 5. Test SSL
curl -I https://yourdomain.com
```

### SSL Auto-renewal Setup

```bash
# Setup automatic renewal on both servers
for server in $SERVER1_IP $SERVER2_IP; do
  ssh root@$server << 'EOF'
    # Add renewal cron job
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    
    # Test renewal (dry run)
    certbot renew --dry-run
EOF
done
```

##  Cleanup

### Destroy Everything

```bash
# Destroy all infrastructure
terraform destroy -auto-approve

# Verify nothing is left
terraform show
```

### Destroy Specific Components

```bash
# Destroy only database
terraform destroy -target="module.database" -auto-approve

# Destroy only servers
terraform destroy -target="module.droplets" -auto-approve

# Destroy only load balancer
terraform destroy -target="module.loadbalancer" -auto-approve
```

### Clean Local Files

```bash
# Remove Terraform state and cache
rm -rf .terraform/
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl

# Remove generated Ansible files
rm -rf ansible/
```

---

## Quick Reference Commands

### Essential Commands
```bash
# Deploy everything
./deploy.sh

# Get load balancer IP
terraform output -raw load_balancer_ip

# Test load balancer
curl http://$(terraform output -raw load_balancer_ip)

# SSH to first server
ssh root@$(terraform output -json droplet_ips | jq -r '.[0]')

# View database credentials
terraform output -json database_connections | jq '.'

# Health check
./health_check.sh

# Destroy everything
terraform destroy -auto-approve
```

### File Locations on Servers
- **Web root**: `/root/api/`
- **Apache config**: `/etc/apache2/sites-available/default.conf`
- **PHP config**: `/etc/php/8.1/apache2/php.ini`
- **Apache logs**: `/var/log/apache2/`
- **SSL certificates**: `/etc/letsencrypt/live/yourdomain.com/`

---

## Next Steps

1. **Deploy your application** files to `/root/api/` on both servers
2. **Configure your database** connections using the provided credentials  
3. **Set up your domain** and SSL certificates for production
4. **Monitor your infrastructure** using the provided health check scripts
5. **Scale as needed** by adding more servers or upgrading resources



---
