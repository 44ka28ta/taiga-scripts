
ZYPPER_OPTIONS='--gpg-auto-import-keys --non-interactive'
ZYPPER_INSTALL_OPTIONS='--force-resolution'

function apt_install {
    for pkg in $@; do
        echo -e "[ZYPPER] Installing package $pkg..."
        sudo zypper ${ZYPPER_OPTIONS} install ${ZYPPER_INSTALL_OPTIONS} $pkg
    done
}


#function apt_install_if_needed {
#    for pkg in $@; do
#        if package_not_installed $pkg; then
#            apt_install $pkg
#        fi
#    done
#}

function apt_install_build_essential {
	sudo zypper ${ZYPPER_OPTIONS} install ${ZYPPER_INSTALL_OPTIONS} --type pattern devel_basis
}


#function package_not_installed {
#    test -z "$(sudo dpkg -s $1 2> /dev/null | grep Status)"
#}

sudo zypper ${ZYPPER_OPTIONS} refresh -f
