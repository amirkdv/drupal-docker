FROM  ${_conf_prj_name}/base

# subst_conf relies on 'envsubst', a utility in the 'gettext' package, stripped
# out in the docker ubuntu image.
RUN apt-get install -y gettext

ADD ./conf    /var/shared/build/conf
ADD ./assets  /var/shared/build/assets/server
ADD ./scripts /var/shared/build/scripts/server

# all configuration file templates live in /var/shared/build/conf
WORKDIR /var/shared/build/conf

# symlink_all_scripts is defined in the base image (installed in /usr/local/bin)
RUN symlink_all_scripts /var/shared/build/scripts/server/ /usr/local/bin/

# Configure Supervisor
RUN subst_conf build_config.sh < supervisord.conf.tpl       > /etc/supervisord.conf
RUN subst_conf build_config.sh < supervisord_light.conf.tpl > /etc/supervisord_light.conf
RUN mkdir -p /var/log/supervisor

# Configure PHP
RUN subst_conf build_config.sh < drupal.ini.tpl > /etc/php5/apache2/conf.d/drupal.ini

# Configure Apache
RUN subst_conf build_config.sh < apache_vhost.tpl > /etc/apache2/sites-available/${_conf_prj_name}
RUN a2enmod rewrite expires && a2dissite default && a2ensite ${_conf_prj_name}

# Configure Solr
RUN mkdir -p /opt/solr/data && cd /opt/solr/ && chown -R tomcat6 . && chmod -R ug+wx . && chmod -R g+s .
RUN subst_conf build_config.sh < context.xml.tpl > /etc/tomcat6/Catalina/localhost/${_conf_prj_name}.xml
RUN ln -sf /var/shared/build/assets/server/solr_1.4.0.war /opt/solr/solr_1.4.0.war

# Configure locale
RUN locale-gen en_CA.utf8 && update-locale LANG=en_CA.utf8

# Configure SSH access
RUN ln -sf /var/shared/build/conf/id_rsa.pub /root/id_rsa.pub
RUN mkdir -p /root/.ssh; chmod 700 /root/.ssh; cat /root/id_rsa.pub >> /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys
RUN mkdir -p /var/run/sshd

# Configure MySQL
RUN initialize_mysql

EXPOSE 80 22 8080
CMD [ "supervisord", "-c" , "/etc/supervisord.conf" , "-n" ]
