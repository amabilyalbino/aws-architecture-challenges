#!/bin/bash
# ==========================================
# EC2 User Data Script - 3-Tier Setup
# ==========================================

# Update and upgrade system packages
apt-get update -y
apt-get upgrade -y

# Install basic tools
apt-get install -y curl wget git unzip htop vim jq software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# --------------------------
# Install Node.js and NPM
# --------------------------
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# --------------------------
# Install MySQL Server
# --------------------------
apt-get install -y mysql-server
systemctl enable mysql
systemctl start mysql

# Secure MySQL and create DB, user, and schema
mysql -e "CREATE DATABASE formapp;"
mysql -e "CREATE USER 'c1_app'@'localhost' IDENTIFIED BY 'SecurePassword123!';"
mysql -e "GRANT ALL PRIVILEGES ON formapp.* TO 'c1_app'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Create submissions table
mysql -e "USE formapp; \
CREATE TABLE submissions ( \
  id VARCHAR(36) PRIMARY KEY, \
  firstName VARCHAR(100) NOT NULL, \
  lastName VARCHAR(100) NOT NULL, \
  email VARCHAR(255) NOT NULL, \
  phone VARCHAR(20), \
  interests VARCHAR(100) NOT NULL, \
  subscription VARCHAR(50) NOT NULL, \
  frequency VARCHAR(50) NOT NULL, \
  comments TEXT, \
  termsAccepted BOOLEAN NOT NULL, \
  submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP \
);"

# --------------------------
# Install NGINX
# --------------------------
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# --------------------------
# Clone Application Repository
# --------------------------
cd /home/ubuntu
git clone https://github.com/DNXLabs/mentorship-challenges.git
cd mentorship-challenges/3-tier-app

# --------------------------
# Configure API
# --------------------------
cd src/api
npm install

# Create environment file for API
cat > .env << EOF
PORT=3000
DB_HOST=localhost
DB_USER=c1_app
DB_PASSWORD=SecurePassword123!
DB_NAME=formapp
EOF

# --------------------------
# Install and Configure PM2
# --------------------------
npm install -g pm2
pm2 start server.js --name "c1_app"
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu

# --------------------------
# Configure NGINX as Reverse Proxy (Correct Root)
# --------------------------
cat > /etc/nginx/sites-available/formapp << 'EOF'
server {
    listen 80;
    server_name _;

    root /home/ubuntu/mentorship-challenges/3-tier-app/src/web;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/formapp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx

# --------------------------
# Fix Permissions (optional but safe)
# --------------------------
chown -R ubuntu:ubuntu /home/ubuntu/mentorship-challenges
chmod -R 755 /home/ubuntu/mentorship-challenges

# --------------------------
# Test Services
# --------------------------
echo "MySQL: $(systemctl is-active mysql)"
echo "NGINX: $(systemctl is-active nginx)"
echo "PM2 Apps:"
pm2 list
