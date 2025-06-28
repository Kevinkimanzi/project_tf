# 🚀 LAMP Stack Infrastructure with Load Balancer

**One-click deployment** of a complete LAMP (Linux, Apache, MySQL, PHP) stack on DigitalOcean with load balancing and database clustering.

## 📦 What You Get

- ✅ **2 Web Servers**: Ubuntu 22.04 + Apache + PHP 8.1
- ✅ **1 Load Balancer**: Traffic distribution between servers  
- ✅ **1 MySQL Cluster**: Managed database with 2 separate databases
- ✅ **1 VPC**: Private networking + firewall protection
- ✅ **SSL Ready**: Pre-configured for SSL certificates

---

## 🛠️ Prerequisites Setup

### Step 1: Install Required Tools

**For macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install terraform ansible jq curl
```

**For Ubuntu/Debian:**
```bash
# Update package list
sudo apt update

# Install all required tools
sudo apt install -y terraform ansible jq curl wget
```

**For CentOS/RHEL:**
```bash
# Install EPEL repository
sudo yum install -y epel-release

# Install required tools
sudo yum install -y terraform ansible jq curl wget
```

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

## 🚀 Quick Deploy (One Command)

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

## 🌐 Access Your Infrastructure

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

### Test Your Deployment

```bash
# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test load balancer (should show server info)
curl http://$LB_IP

```

### SSH Access to Servers

```bash
# Get server IPs
SERVER1_IP=$(terraform output -json droplet_ips | jq -r '.[0]')
SERVER2_IP=$(terraform output -json droplet_ips | jq -r '.[1]')

# SSH into first server
ssh root@$SERVER1_IP

# SSH into second server
ssh root@$SERVER2_IP
```

---

## 🗄️ Database Setup & Testing

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

---

## 📁 Deploy Your PHP Application

### Method 1: Using rsync (Recommended)

```bash
# Get server IPs
SERVER1_IP=$(terraform output -json droplet_ips | jq -r '.[0]')
SERVER2_IP=$(terraform output -json droplet_ips | jq -r '.[1]')

# Upload your PHP application to both servers
rsync -avz --delete ./your-php-app/ root@$SERVER1_IP:/root/api/
rsync -avz --delete ./your-php-app/ root@$SERVER2_IP:/root/api/

# Verify upload
ssh root@$SERVER1_IP "ls -la /root/api/"
```

### Method 2: Using scp

```bash
# Create a zip of your application
tar -czf myapp.tar.gz ./your-php-app/

# Copy to servers
scp myapp.tar.gz root@$SERVER1_IP:/root/
scp myapp.tar.gz root@$SERVER2_IP:/root/

# Extract on servers
ssh root@$SERVER1_IP "cd /root && tar -xzf myapp.tar.gz && mv your-php-app/* api/ && rm myapp.tar.gz"
ssh root@$SERVER2_IP "cd /root && tar -xzf myapp.tar.gz && mv your-php-app/* api/ && rm myapp.tar.gz"
```

### Method 3: Git Deployment

```bash
# SSH into each server and clone your repository
ssh root@$SERVER1_IP << 'EOF'
cd /root/api
git init
git remote add origin https://github.com/yourusername/your-php-app.git
git pull origin main
EOF

ssh root@$SERVER2_IP << 'EOF'
cd /root/api  
git init
git remote add origin https://github.com/yourusername/your-php-app.git
git pull origin main
EOF
```

### Example PHP Database Connection

Create this file as `/root/api/config/database.php` on both servers:

```php
<?php
// Database configuration - auto-generated by Terraform
$db_config = [
    'app1' => [
        'host' => 'YOUR_DB_HOST_FROM_TERRAFORM_OUTPUT',
        'port' => 25060,
        'database' => 'webapp1', 
        'username' => 'appuser1',
        'password' => 'YOUR_PASSWORD_FROM_TERRAFORM_OUTPUT'
    ],
    'app2' => [
        'host' => 'YOUR_DB_HOST_FROM_TERRAFORM_OUTPUT',
        'port' => 25060,
        'database' => 'webapp2',
        'username' => 'appuser2', 
        'password' => 'YOUR_PASSWORD_FROM_TERRAFORM_OUTPUT'
    ]
];

// Connect to database 1
function getDatabase1Connection() {
    global $db_config;
    $config = $db_config['app1'];
    $dsn = "mysql:host={$config['host']};port={$config['port']};dbname={$config['database']}";
    
    try {
        $pdo = new PDO($dsn, $config['username'], $config['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        return $pdo;
    } catch(PDOException $e) {
        die("Database connection failed: " . $e->getMessage());
    }
}

// Usage example:
// $db = getDatabase1Connection();
// $stmt = $db->query("SELECT 'Hello World' as message");
// echo $stmt->fetch()['message'];
?>
```

### Test Your Application

```bash
# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)

# Test main page
curl http://$LB_IP/

# Test a specific PHP file
curl http://$LB_IP/your-file.php

# Test with headers to see which server responds
curl -I http://$LB_IP/
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

---

## 🧪 Testing & Monitoring

### Basic Health Checks

```bash
# Create health check script
cat > health_check.sh << 'EOF'
#!/bin/bash

LB_IP=$(terraform output -raw load_balancer_ip)
SERVER1_IP=$(terraform output -json droplet_ips | jq -r '.[0]')
SERVER2_IP=$(terraform output -json droplet_ips | jq -r '.[1]')

echo "=== Health Check Results ==="
echo "Load Balancer ($LB_IP): $(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)"
echo "Server 1 ($SERVER1_IP): $(curl -s -o /dev/null -w "%{http_code}" http://$SERVER1_IP)"  
echo "Server 2 ($SERVER2_IP): $(curl -s -o /dev/null -w "%{http_code}" http://$SERVER2_IP)"
echo "=========================="
EOF

chmod +x health_check.sh
./health_check.sh
```

### Load Testing

```bash
# Install Apache Bench
sudo apt install -y apache2-utils

# Basic load test
LB_IP=$(terraform output -raw load_balancer_ip)
ab -n 100 -c 10 http://$LB_IP/

# Detailed load test with results
ab -n 1000 -c 50 -g loadtest_results.tsv http://$LB_IP/
```

### Database Performance Test

```bash
# Create database performance test
SERVER1_IP=$(terraform output -json droplet_ips | jq -r '.[0]')

ssh root@$SERVER1_IP << 'EOF'
# Create performance test script
cat > /root/db_performance_test.php << 'PHPEOF'
<?php
$start = microtime(true);

// Database connection details from Terraform output
$host = 'YOUR_DB_HOST';
$port = 25060;
$dbname = 'webapp1';
$username = 'appuser1';
$password = 'YOUR_DB_PASSWORD';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname", $username, $password);
    
    // Simple performance test
    for ($i = 0; $i < 100; $i++) {
        $stmt = $pdo->query("SELECT NOW() as current_time");
        $result = $stmt->fetch();
    }
    
    $end = microtime(true);
    echo "100 queries completed in: " . round($end - $start, 4) . " seconds\n";
    
} catch(PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
PHPEOF

# Run the test
php /root/db_performance_test.php
EOF
```

---

## ⚙️ Customization & Scaling

### Change Configuration

```bash
# Edit variables before deployment
nano variables.tf

# Example customizations:
# - Change region: variable "region" { default = "fra1" }
# - Change server names: variable "droplet_names" { default = ["api-1", "api-2", "api-3"] }
# - Change server size: variable "droplet_size" { default = "s-2vcpu-2gb" }

# Apply changes
terraform apply -auto-approve
```

### Add More Servers

```bash
# 1. Edit variables.tf to add more server names
nano variables.tf

# 2. Apply changes
terraform apply -auto-approve

# 3. Configure new servers
cd ansible
ansible-playbook -i inventory.ini setup.yml
cd ..
```

### Scale Database

```bash
# Upgrade database size
terraform apply -var="database_size=db-s-2vcpu-2gb" -auto-approve
```

---

## 🔧 Troubleshooting

### Check Service Status

```bash
# Check all servers at once
for server in $(terraform output -json droplet_ips | jq -r '.[]'); do
  echo "=== Server $server ==="
  ssh root@$server << 'EOF'
    echo "Apache status: $(systemctl is-active apache2)"
    echo "PHP status: $(php -v | head -1)"
    echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"
    echo "Memory usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
    echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
EOF
  echo ""
done
```

### Debug Apache Issues

```bash
# Get server IP and check Apache
SERVER1_IP=$(terraform output -json droplet_ips | jq -r '.[0]')

ssh root@$SERVER1_IP << 'EOF'
# Check Apache status
systemctl status apache2

# Check Apache error logs
tail -20 /var/log/apache2/error.log

# Check Apache access logs  
tail -20 /var/log/apache2/access.log

# Test Apache configuration
apache2ctl configtest

# Restart Apache if needed
systemctl restart apache2
EOF
```

### Debug Database Issues

```bash
# Test database connectivity
DB_HOST=$(terraform output -json database_connections | jq -r '.app1.host')
DB_USER=$(terraform output -json database_connections | jq -r '.app1.username')
DB_PASS=$(terraform output -json database_connections | jq -r '.app1.password')

# Test connection with timeout
timeout 10 mysql -h $DB_HOST -P 25060 -u $DB_USER -p$DB_PASS -e "SELECT 1;" 2>&1
echo "Connection test exit code: $?"
```

### Debug Load Balancer

```bash
# Check load balancer health
LB_IP=$(terraform output -raw load_balancer_ip)

# Test each backend server
for i in {1..10}; do
  response=$(curl -s http://$LB_IP | grep "Server:")
  echo "Request $i: $response"
  sleep 1
done

# Check if load balancer is distributing traffic evenly
```

### Get Comprehensive System Info

```bash
# Create system info script
cat > system_info.sh << 'EOF'
#!/bin/bash

echo "=== LAMP Stack Infrastructure Status ==="
echo "Date: $(date)"
echo ""

# Infrastructure details
echo "--- Infrastructure ---"
echo "Load Balancer IP: $(terraform output -raw load_balancer_ip)"
echo "Server IPs: $(terraform output -json droplet_ips | jq -r '.[]' | tr '\n' ' ')"
echo ""

# Test connectivity
echo "--- Connectivity Tests ---"
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer HTTP: $(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)"

for server in $(terraform output -json droplet_ips | jq -r '.[]'); do
  echo "Server $server HTTP: $(curl -s -o /dev/null -w "%{http_code}" http://$server)"
done
echo ""

# Database connectivity
echo "--- Database Status ---"
DB_HOST=$(terraform output -json database_connections | jq -r '.app1.host')
DB_USER=$(terraform output -json database_connections | jq -r '.app1.username')
DB_PASS=$(terraform output -json database_connections | jq -r '.app1.password')

if timeout 5 mysql -h $DB_HOST -P 25060 -u $DB_USER -p$DB_PASS -e "SELECT 1;" &>/dev/null; then
  echo "Database connection: ✅ SUCCESS"
else
  echo "Database connection: ❌ FAILED"
fi

echo ""
echo "=== End Status Report ==="
EOF

chmod +x system_info.sh
./system_info.sh
```

---

## 🧹 Cleanup

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

## 📋 Quick Reference Commands

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

## 🎯 Next Steps

1. **Deploy your application** files to `/root/api/` on both servers
2. **Configure your database** connections using the provided credentials  
3. **Set up your domain** and SSL certificates for production
4. **Monitor your infrastructure** using the provided health check scripts
5. **Scale as needed** by adding more servers or upgrading resources

**Happy coding!** 🚀

---

## 📞 Support

For issues with this infrastructure setup:
1. Check the troubleshooting section above
2. Review DigitalOcean documentation
3. Verify your API token and permissions
4. Ensure all prerequisites are installed correctly