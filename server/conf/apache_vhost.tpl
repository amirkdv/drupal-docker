<VirtualHost *:80>
  ServerName ${_conf_prj_name}
  ServerAlias ${_conf_prj_name}
  DocumentRoot ${_conf_drupal_root}
  RewriteEngine On

  <Directory ${_conf_drupal_root}>
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>

  LogLevel info
  ErrorLog /var/log/apache2/${_conf_prj_name}-error.log
  CustomLog /var/log/apache2/${_conf_prj_name}-access.log combined
</VirtualHost>
