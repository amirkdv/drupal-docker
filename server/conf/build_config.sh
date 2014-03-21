#!/bin/bash

# deployment configuration
_conf_prj_name=my_project
_conf_prj_root=/var/shared/sites/${_conf_prj_name}
_conf_drupal_root="${_conf_prj_root}/site"

# Database credentials and connection info
_conf_db_root=root
_conf_db_name=drupal
_conf_db_user=drupal
_conf_db_pass=drupal
_conf_db_host=localhost
_conf_db_conn="mysql --skip-column-names --batch --host=${_conf_db_host} --user=root --password=${_conf_db_root} --database=${_conf_db_name}"

# Drupal user 1 credentials
_conf_admin_username=admin
_conf_admin_password=admin

# Solr configuration
_conf_solr_home=${_conf_prj_root}/solr_home
_conf_solr_data=/opt/solr/data
