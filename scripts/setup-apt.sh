
ZYPPER_OPTIONS='--gpg-auto-import-keys --non-interactive'

function apt-install {
    for pkg in $@; do
        echo -e "[APT-GET] Installing package $pkg..."
        sudo zypper ${ZYPPER_OPTIONS} install $pkg
    done
}


#function apt-install-if-needed {
#    for pkg in $@; do
#        if package-not-installed $pkg; then
#            apt-install $pkg
#        fi
#    done
#}

function apt-install-build-essential {
	sudo zypper ${ZYPPER_OPTIONS} install --type pattern devel_basis
}


#function package-not-installed {
#    test -z "$(sudo dpkg -s $1 2> /dev/null | grep Status)"
#}

sudo zypper ${ZYPPER_OPTIONS} refresh -f
