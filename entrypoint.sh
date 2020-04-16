#!/bin/bash

set -e
echo "Running the entrypoint.sh script..."

create_pid_dir() {
  mkdir -p /run/apt-cacher-ng
  chmod -R 0755 /run/apt-cacher-ng
  chown ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} /run/apt-cacher-ng
}

create_cache_dir() {
  mkdir -p ${APT_CACHER_NG_CACHE_DIR}
  chmod -R 0755 ${APT_CACHER_NG_CACHE_DIR}
  chown -R ${APT_CACHER_NG_USER}:root ${APT_CACHER_NG_CACHE_DIR}
}

create_log_dir() {
  mkdir -p ${APT_CACHER_NG_LOG_DIR}
  chmod -R 0755 ${APT_CACHER_NG_LOG_DIR}
  chown -R ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} ${APT_CACHER_NG_LOG_DIR}
}

create_pid_dir
create_cache_dir
create_log_dir

# Start Supervisor
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
# echo "meh"
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error while starting the supervisor daemon"
    exit $retVal
fi

echo "...done with entrypoint.sh"

exit 0