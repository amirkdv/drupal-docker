#!/bin/bash
source /var/shared/build/conf/build_config.sh

log() { echo -e "\033[0;34m[$( basename $0)] $1\033[00m" >&2; }

declare -r drush="drush --root=${_conf_drupal_root}"
declare -r supervisord="/usr/local/bin/supervisord -c     /etc/supervisord_light.conf"
declare -r supervisorctl="/usr/local/bin/supervisorctl -c /etc/supervisord_light.conf"

supervisor_running(){
  if $supervisorctl avail >/dev/null 2>&1; then
    log "supervisord is running"
  else
    $supervisord
    touch /tmp/supervisor_helpers_started
    log "started supervisord"
  fi
  sleep 0.5s
}

# $1 must be supervisor program name
supervisor_service_up(){
  program="$1"
  if [[ -z $program ]]; then
    log "expects the first argument to be a supervisor controlled program"
    exit 1
  fi
  supervisor_running
  if $supervisorctl start $program | grep -q 'already started'; then
    log "$program is already running"
  else
    touch "/tmp/supervisor_helpers_started_$program"
    log "started $program"
    # supervised MySQL has some timing issues:
    [[ $program == 'mysql' ]] && sleep 1s
  fi
}

supervisor_services_done(){
  log "stopping started programs"
  for file in $( ls /tmp/supervisor_helpers_started_* ); do
    # expectes the files to be of the form supervisor_helpers_started_[program]
    program="$( basename $file | cut -d_ -f4- )"
    $supervisorctl stop "$program" 1>&2
    log "stopped $program"
    # supervised MySQL has some timing issues:
    [[ $program == 'mysql' ]] && sleep 1s
    rm $file
  done
  if [[ -f /tmp/supervisor_helpers_started ]]; then
    $supervisorctl shutdown 1>&2
    log "stopped supervisor"
    rm /tmp/supervisor_helpers_started
  fi
}
