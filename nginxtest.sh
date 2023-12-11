#!/bin/bash

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/nginx.conf"

# Define the upstream and server configurations
upstream_config="upstream backend {
    server 52.66.250.19:8889;
}

upstream grafana_backend {
    server 127.0.0.1:3000;
}"

server_config="server {
    listen 80;
    server_name ec2-3-109-54-36.ap-south-1.compute.amazonaws.com;

    location / {
        proxy_pass http://backend;
    }

    location /grafana/ {
        proxy_pass http://grafana_backend/;
    }
}"

# Create a temporary file for modifications
temp_file=$(mktemp)

# Add upstream configuration to the temporary file
awk -v upstream="$upstream_config" '/^http {/ { print; print upstream; next }1' "$nginx_conf" > "$temp_file"

# Add server configuration to the temporary file
awk -v server="$server_config" '/include \/etc\/nginx\/sites-enabled\/\*;/ { print server; next }1' "$temp_file" > "$nginx_conf"

# Comment out the line 'include /etc/nginx/sites-enabled/*;' in the Nginx configuration file
sed -i 's/include \/etc\/nginx\/sites-enabled\/\*;/#&/' "$nginx_conf"

# Test the Nginx configuration
sudo nginx -t

# Reload Nginx only if the configuration test is successful
if [ $? -eq 0 ]; then
    sudo service nginx reload
    echo "Nginx configuration updated successfully."
else
    echo "Nginx configuration test failed. Please check the configuration for errors."
fi

# Remove the temporary file
rm "$temp_file"
