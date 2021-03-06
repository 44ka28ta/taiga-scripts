if [ ! -e ~/.setup/buildessential ]; then
    touch ~/.setup/buildessential

    #apt_install_if_needed build-essential binutils-doc autoconf flex bison libjpeg-dev libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev automake libtool libffi-dev curl gettext cairo
	apt_install_build_essential
    apt_install libopenssl-devel autoconf flex bison libjpeg8-devel libjpeg62-devel libfreetype6 freetype2-devel zlib-devel libzmq5 zeromq-devel gdbm-devel ncurses-devel automake libtool libffi48-devel curl gettext-tools cairo-tools

    # Utils
    apt_install git tmux
fi
