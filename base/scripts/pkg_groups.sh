#!/bin/bash

declare -A pkg_group
pkg_group[lamp_basic]="apache2 libapache2-mod-php5 php5-mysql mysql-server"
pkg_group[php_extras]="php5 php5-cli php5-curl php5-gd php5-memcache"
pkg_group[pear]="php5-dev build-essential php-pear libpcre3-dev"
pkg_group[tomcat]="openjdk-6-jdk tomcat6"
pkg_group[dev_tools]="git curl vim openssh-server mysql-client sudo man-db memcached netcat pv"

pkg_group_install(){
  for group in "$@"; do
    log "installing APT package group '$group': ${pkg_group[$group]} ..."
    apt-get install -y ${pkg_group[$group]}
  done
  apt-get clean
}
