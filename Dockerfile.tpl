FROM ${_conf_prj_name}/data

ADD ./scripts /var/shared/build/scripts/drupal/
RUN symlink_all_scripts /var/shared/build/scripts/drupal /usr/local/bin

ADD ./project /var/shared/sites/${_conf_prj_name}

RUN fix_drupal_permissions
RUN adjust_user_one

EXPOSE 80 22 8080
CMD [ "supervisord", "-c" , "/etc/supervisord.conf" , "-n" ]
