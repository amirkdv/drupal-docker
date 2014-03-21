FROM  ubuntu:12.04

ADD ./scripts/symlink_all_scripts /usr/local/bin/symlink_all_scripts
ADD ./scripts /var/deploy/scripts/base/

RUN chmod +x /usr/local/bin/symlink_all_scripts && \
    symlink_all_scripts /var/deploy/scripts/base/ /usr/local/bin/

RUN apt-get update

# hijack /sbin/initctl
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s -f /bin/true /sbin/initctl

ENV DEBIAN_FRONTEND noninteractive

# install minimal LAMP stack: apache2 libapache2-mod-php5 php5-mysql mysql-server
RUN dependencies pkg_group_install lamp_basic
# install extra php modules/packages php5 php5-{cli,curl,gd,memcache}
RUN dependencies pkg_group_install php_extras
# install packages required for PEAR extensions
RUN dependencies pkg_group_install pear
# install git vim curl mysql-client memcached and openssh-server
RUN dependencies pkg_group_install dev_tools
# install PEAR/PECL extensions
RUN dependencies pear_extension_install apc xhprof uploadprogress phpunit
# install openjdk-6-jdk and tomcat6
RUN dependencies pkg_group_install tomcat
# install drush via composer
RUN dependencies install drush postfix supervisor
