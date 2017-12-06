#!/bin/bash

if [ "$scheme" = "https" ]; then

    PIN_SHA256=`openssl x509 -in $cert_file -pubkey -noout | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -binary | openssl enc -base64`

    DHPARAM_PATH='/etc/ssl/dhparam.pem'

    sudo openssl dhparam 2048 -out /etc/ssl/dhparam.pem


    cat > /tmp/taiga.conf <<EOF
server {
    listen 443 ssl default_server;
    server_name $hostname;

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

    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header Public-Key-Pins 'pin-sha256="$PIN_SHA256"; max-age=2592000; includeSubDomains';

    ssl on;
    ssl_certificate $cert_file;
    ssl_certificate_key $key_file;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
    ssl_session_cache shared:SSL:10m;
    ssl_dhparam $DHPARAM_PATH;
    ssl_stapling on;
    ssl_stapling_verify on;
}
EOF


else

    cat > /tmp/taiga.conf <<EOF
server {
    listen 80 default_server;
    listen 8000 default_server;
    server_name $hostname;

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

fi

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
