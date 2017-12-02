# rabbitmq.sh

function rabbit_create_user_if_needed {
    username=$1
    password=$2
    $(sudo rabbitmqctl list_users | grep -q "$username") || sudo rabbitmqctl add_user $username $password
}

function rabbit_create_vhost_if_needed {
    vhost=$1
    $(sudo rabbitmqctl list_vhosts | grep -q "$vhost") || sudo rabbitmqctl add_vhost $vhost
}

function rabbit_set_permissions {
    username=$1
    vhost=$2
    configure=$3
    write=$4
    read=$5
    sudo rabbitmqctl set_permissions -p $vhost $username "$configure" "$write" "$read"
}

function rabbit_activate_plugin {
    plugin=$1
    if ! grep -q "$plugin" /etc/rabbitmq/enabled_plugins; then
        sudo rabbitmq-plugins enable "$plugin"
        sudo /etc/init.d/rabbitmq-server stop
        sudo rabbitmqctl stop
        sudo /etc/init.d/rabbitmq-server start
    fi
}


if [ ! -e ~/.setup/rabbitmq ]; then
    touch ~/.setup/rabbitmq

    apt_install rabbitmq-server
fi
