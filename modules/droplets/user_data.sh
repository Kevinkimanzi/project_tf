# #!/bin/bash
# apt-get update
# apt-get install -y apache2 mysql-client

# # Configure default site
# cat > /etc/apache2/sites-available/000-default.conf << 'EOF'
# <VirtualHost *:80>
#     ServerAdmin webmaster@localhost
#     DocumentRoot /var/www/html
#     ErrorLog ${APACHE_LOG_DIR}/error.log
#     CustomLog ${APACHE_LOG_DIR}/access.log combined
# </VirtualHost>
# EOF

# # Create index page
# cat > /var/www/html/index.html << EOF
# <h1>Hello from ${server_name}!</h1>
# <p>Apache server running on $(hostname)</p>
# <p>Server provisioned at $(date)</p>
# EOF

# # Start and enable Apache
# systemctl start apache2
# systemctl enable apache2
# a2ensite 000-default
# systemctl reload apache2