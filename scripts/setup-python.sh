#!/bin/bash

#apt_install_if_needed python3 python3-pip python-dev python3-dev python-pip virtualenvwrapper libxml2-dev libxslt1-dev
apt_install python3 python3-pip python-devel python3-devel python-pip python-virtualenvwrapper libxml2-devel libxslt-devel
source /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh

function mkvirtualenv_if_needed {
    for envname in $@; do
        #$(lsvirtualenv | grep -q "$envname") || mkvirtualenv "$envname" -p /usr/bin/python3.5
        $(lsvirtualenv | grep -q "$envname") || mkvirtualenv "$envname" -p /usr/bin/python3
    done
}
