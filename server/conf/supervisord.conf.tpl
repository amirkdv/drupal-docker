; supervisor configuration file, if this configuration file is used
; supervisord will run in the foreground and will automatically start all
; programs. Use this configuration file with the -n option  in Dockefile CMD:
; supervisord -c /etc/supervisord.conf -n

[unix_http_server]
file=/tmp/supervisor.sock ; (the path to the socket file, cf. [supervisorctl]

[supervisord]
logfile=/var/log/supervisord.log
pidfile=/tmp/supervisord.pid
; nodaemon=true ; This is the intended use case but do not specify this here,
                ; that would break supervisord_light.conf, use the --no-daemon [-n]
                ; option when using this config file instead

[supervisorctl]
serverurl = unix:///tmp/supervisor.sock

; the below section must remain in the config file for supervisorctl to work
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[program:mysql]
command=/usr/local/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/bin/mysqld_safe
        --log-error=/var/log/mysql/error.log
;       --general_log=1 --general_log_file=/var/log/mysql/access.log ; log all queries

[program:apache]
environment= APACHE_LOG_DIR="/var/log/apache2",
             APACHE_LOCK_DIR="/var/lock/apache2",
             APACHE_RUN_USER="www-data",
             APACHE_RUN_GROUP="www-data",
             APACHE_PID_FILE="/var/run/apache.pid",
             APACHE_RUN_DIR="/var/run/apache2",
             LANG="C"
command=/usr/sbin/apache2 -D FOREGROUND

[program:memcached]
command=/usr/bin/memcached -v -m 64 -p 11211 -U 11211 -u nobody -l 127.0.0.1 -c 1024 -I 1m
stdout_logfile=/var/log/memcached.log
stderr_logfile=/var/log/memcached.log


[program:ssh]
command=/usr/sbin/sshd -D

[program:tomcat]
environment= TOMCAT6_USER=tomcat6,
             TOMCAT6_GROUP=tomcat6,
             JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64,
             CATALINA_HOME=/usr/share/tomcat6,
             CATALINA_BASE=/var/lib/tomcat6
command=/usr/share/tomcat6/bin/catalina.sh run
user=tomcat6
