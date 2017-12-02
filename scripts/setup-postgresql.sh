# postgresql.sh

function createdb_if_needed {
    for dbname in $@; do
        $(psql -l | grep -q "$dbname") || createdb "$dbname"
    done
}

function dropdb_if_needed {
    for dbname in $@; do
        $(psql -l | grep -q "$dbname") && dropdb "$dbname"
    done
}

if [ ! -e ~/.setup/postgresql ]; then
    #apt_install postgresql95 postgresql95-contrib \
    #    postgresql95-doc postgresql95-server postgresql95-devel
    apt_install postgresql95 postgresql95-contrib \
        postgresql95-server postgresql95-devel

    sudo -u postgres createuser --superuser $USER &> /dev/null
    sudo -u postgres createdb $USER &> /dev/null

    touch ~/.setup/postgresql
fi

