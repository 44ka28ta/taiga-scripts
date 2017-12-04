#!/bin/bash

cat > /tmp/taiga.conf <<EOF
server {
    listen 80 default_server;
    listen 8000 default_server;
    server_name _;

    large_client_header_buffers 4 32k;

    client_max_body_size 50M;
    charset utf-8;

    access_log /home/$USER/logs/nginx.access.log;
    error_log /home/$USER/logs/nginx.error.log;

    location / {
        root /home/$USER/taiga-front/dist/;
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:8001/api;
        proxy_redirect off;
    }
    
    # Django admin access (/admin/)
    location /admin {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:8001\$request_uri;
        proxy_redirect off;
    }

    location /static {
        alias /home/$USER/taiga-back/static;
    }

    location /media {
        alias /home/$USER/taiga-back/media;
    }
}
EOF

apt_install nginx
# sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf

SITES_AVAIL_PATH="/etc/nginx/sites-available"
SITES_ENABLED_PATH="/etc/nginx/sites-enabled"

sudo mkdir -p ${SITES_AVAIL_PATH}
sudo mkdir -p ${SITES_ENABLED_PATH}

sudo mv /tmp/taiga.conf ${SITES_AVAIL_PATH}/taiga
sudo rm -rf ${SITES_ENABLED_PATH}/taiga
sudo rm -rf ${SITES_ENABLED_PATH}/default
sudo ln -s ${SITES_AVAIL_PATH}/taiga ${SITES_ENABLED_PATH}/taiga
sudo sed -i 's/include vhosts.d\/\*\.conf;/include sites-enabled\/*;/' /etc/nginx/nginx.conf
sudo systemctl restart nginx
sudo systemctl enable nginx
