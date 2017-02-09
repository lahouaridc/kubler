#
# build config, sourced by build-root.sh inside build container
#
PACKAGES=""
EMERGE_BIN="emerge"

#
# this hook can be used to configure the build container itself, install packages, etc
#
configure_bob() {
    # install flaggie, required for update_use() helper
    emerge app-portage/flaggie
    mv /etc/portage/package.accept_keywords /etc/portage/foo
    mkdir -p /etc/portage/package.{accept_keywords,unmask,mask,use}
    mv /etc/portage/foo /etc/portage/package.accept_keywords/flaggie
    touch /etc/portage/package.accept_keywords/flaggie
    # set locale of build container
    #echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
    # not supported with musl
    #locale-gen
    echo 'LANG="en_US.UTF-8"' > /etc/env.d/02locale
    env-update
    source /etc/profile
    # install default packages
    update_use 'dev-vcs/git' '-perl'
    update_use 'app-crypt/pinentry' '+ncurses'
    update_keywords 'app-portage/layman' '+~amd64'
    update_keywords 'dev-python/ssl-fetch' '+~amd64'
    emerge dev-vcs/git app-portage/layman sys-devel/distcc app-misc/jq app-portage/eix
    # init eix portage db
    eix-update
    # setup layman
    sed -i 's/^check_official : Yes/check_official : No/g' /etc/layman/layman.cfg # no pesky prompts please
    layman -L
    layman -a musl
    # install acbuild
    #emerge dev-lang/go app-crypt/gnupg
    #git clone https://github.com/containers/build
    #cd build/ && ./build
    #cp ./bin/acbuild* /usr/local/bin/
    #cd ..
    #rm -r build/
}

#
# this hook is called in the build container just before tar'ing the rootfs
#
finish_rootfs_build()
{
    :
}
