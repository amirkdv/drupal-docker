FROM ${_conf_prj_name}/data

ADD ./scripts /var/shared/build/scripts/drupal/
RUN symlink_all_scripts /var/shared/build/scripts/drupal /usr/local/bin

ADD ./project /var/shared/sites/${_conf_prj_name}

ADD ./setting.local.php.tpl /var/shared/build/conf/drupal/settings.local.php.tpl
RUN subst_conf /var/shared/build/conf/build_config.sh < \
    /var/shared/build/conf/drupal/settings.local.php.tpl | \
    tee /var/shared/sites/${_conf_prj_name}/site/sites/default/settings.local.php

RUN fix_drupal_permissions
RUN adjust_user_one
# RUN additional scripts

EXPOSE 80 22 8080
CMD [ "supervisord", "-c" , "/etc/supervisord.conf" , "-n" ]
