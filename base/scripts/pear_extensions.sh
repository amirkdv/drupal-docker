#!/bin/bash

declare -A pear_extension
# For each PHP extension the following attributes are defined:
# 1 pear_extensions[<extension>_channel]
#     PEAR channel to use for installation; default 'pear.php.net'
# 2 pear_extensions[<extension>_state]
#     preferred state to install; default 'stable'.
pear_extension[xhprof_channel]="pecl.php.net"
pear_extension[xhprof_state]="beta"
pear_extension[uploadprogress_channel]="pecl.php.net"
pear_extension[apc_channel]="pecl.php.net"
pear_extension[phpunit_channel]="pear.phpunit.de"

# Arguments are PEAR extension names
#
# Assumes prerequisite APT packages are already installed,
# cf packages[pear], to install: 'apt_install pear'
pear_extension_install(){
  pear config-set auto_discover 1
  for package in "$@"; do
    log "installing PHP extension $package ..."
    declare channel=${pear_extension["$package"_channel]};
    channel=${channel:-'pear.php.net'}
    declare state=${pear_extension["$package"_state]:-'stable'}
    /usr/bin/pear channel-info $channel || pear channel-discover $channel
    # use defaults in pear install prompts
    printf "\n" | /usr/bin/pear install "channel://$channel/$package-$state"
  done
}
