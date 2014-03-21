FROM ${_conf_prj_name}/server

ADD ./assets  /var/shared/build/assets/data
ADD ./scripts /var/shared/build/scripts/data
RUN symlink_all_scripts /var/shared/build/scripts/data /usr/local/bin

# populate MySQL database
RUN load_mysql_dump /var/shared/build/assets/data/dump.sql.gz   drupal

# populate Solr cached index
RUN load_solr_dump /var/shared/build/assets/data/solr_1.4.0_data.tar.gz
