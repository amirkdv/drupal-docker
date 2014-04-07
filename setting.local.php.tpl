<?php
/* dummy settings.local.php for D6 and D7
** to be included from settings.php
*/
$db_url = "mysql://${_conf_db_user}:${_conf_db_pass}@${_conf_db_host}/${_conf_db_name}";
$databases['default']['default'] = array(
  'driver'   => 'mysql',
  'host'     => '${_conf_db_host}',
  'database' => '${_conf_db_name}',
  'username' => '${_conf_db_user}',
  'password' => '${_conf_db_pass}'
);
