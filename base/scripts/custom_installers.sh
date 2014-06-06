#!/bin/bash
custom_install(){
  for package in "$@"; do
    case "$package" in
      drush)
        log "installing composer"
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
        log "installing drush"
        composer global require drush/drush:6.*
        ln -sf /.composer/vendor/drush/drush/drush /usr/bin/drush
        ;;
      postfix)
        log "installing postfix ..."
        echo "postfix postfix/mailname string example.com" | debconf-set-selections
        echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
        apt-get install -y postfix
        apt-get clean
        ;;
      supervisor)
        log "installing supervisor ..."
        apt-get install -y python-setuptools
        apt-get clean
        easy_install supervisor
        ;;
      *)
        printf "argument list $@ won't do!\n"
        return 1
        ;;
    esac
  done
}
