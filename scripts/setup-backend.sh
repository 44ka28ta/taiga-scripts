#!/bin/bash

BACKEND_VERSION="stable"

pushd ~

cat > /tmp/settings.py <<EOF
from .common import *

MEDIA_URL = "$scheme://$hostname/media/"
STATIC_URL = "$scheme://$hostname/static/"

# This should change if you want generate urls in emails
# for external dns.
SITES["front"]["scheme"] = "$scheme"
SITES["front"]["domain"] = "$hostname"

DEBUG = True
PUBLIC_REGISTER_ENABLED = True

DEFAULT_FROM_EMAIL = "no-reply@example.com"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

#EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
#EMAIL_USE_TLS = False
#EMAIL_HOST = "localhost"
#EMAIL_HOST_USER = ""
#EMAIL_HOST_PASSWORD = ""
#EMAIL_PORT = 25

EOF

if [ ! -e ~/taiga-back ]; then
    createdb_if_needed taiga
    git clone https://github.com/taigaio/taiga-back.git taiga-back

    pushd ~/taiga-back
    git checkout -f stable

    # rabbit_create_user_if_needed taiga taiga  # username, password
    # rabbit_create_vhost_if_needed taiga
    # rabbit_set_permissions taiga taiga ".*" ".*" ".*" # username, vhost, configure, read, write
    mkvirtualenv_if_needed taiga

    # Settings
    mv /tmp/settings.py settings/local.py
    workon taiga

    pip3 install -r requirements.txt
    python3 manage.py migrate --noinput
    python3 manage.py compilemessages
    python3 manage.py collectstatic --noinput
    python3 manage.py loaddata initial_user
    python3 manage.py loaddata initial_project_templates
    python3 manage.py sample_data
    python3 manage.py rebuild_timeline --purge

    deactivate
    popd
else
    pushd ~/taiga-back
    git fetch
    git checkout -f stable
    git reset --hard origin/stable

    workon taiga
    pip3 install -r requirements.txt
    python3 manage.py migrate --noinput
    python3 manage.py compilemessages
    python3 manage.py collectstatic --noinput
    sudo systemctl restart circus
	popd
fi

popd
