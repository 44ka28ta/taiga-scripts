#!/bin/bash

#apt-install-if-needed python3 python3-pip python-dev python3-dev python-pip virtualenvwrapper libxml2-dev libxslt1-dev
apt-install python3 python3-pip python-devel python3-devel python-pip python-virtualenvwrapper libxml2-devel libxslt-devel
source /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh

function mkvirtualenv-if-needed {
    for envname in $@; do
        $(lsvirtualenv | grep -q "$envname") || mkvirtualenv "$envname" -p /usr/bin/python3.5
    done
}
