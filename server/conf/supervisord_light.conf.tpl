; supervisor configuration file, if this configuration file is used
; supervisord will run as a daemon and will not automatically start any of
; the programs. To start individual programs use supervisorctl

[include]
files=/etc/supervisord.conf

[supervisord]
nodaemon=false ; this is the default, put here for clarity

[supervisorctl]
serverurl = unix:///tmp/supervisor.sock

[program:mysql]
autostart=false

[program:apache]
autostart=false

[program:memcached]
autostart=false

[program:ssh]
autostart=false

[program:tomcat]
autostart=false
