# redis.sh

if [ ! -e ~/.setup/redis ]; then
    touch ~/.setup/redis

    #apt_install_if_needed redis-server
    apt_install redis
fi
