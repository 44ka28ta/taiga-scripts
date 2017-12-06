mkdir -p ~/.setup

if [ -e ~/.setup/data.sh ]; then
    source ~/.setup/data.sh
else
    echo -n "Scheme (default http): "
    read scheme
    echo -n "Hostname (default: localhost): "
    read hostname

    if [ -z "$hostname" ]; then
        hostname="localhost"
    fi

    if [ -z "$scheme" ]; then
        scheme="http"
    fi

    if [ "$scheme" = "https" ]; then
        echo -n "Server Certificate File: "
        read input_cert_file
        cert_file=`readlink -f ${input_cert_file}`
        echo -n "Server Key File: "
        read input_key_file
        key_file=`readlink -f ${input_key_file}`
        echo "Installing taigaio with user=$USER host=$hostname scheme=$scheme cert_file=$cert_file key_file=$key_file"
    else
        echo "Installing taigaio with user=$USER host=$hostname scheme=$scheme"
    fi
fi

sleep 2
