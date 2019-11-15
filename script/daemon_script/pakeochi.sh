#! /bin/sh
### BEGIN INIT INFO
# Provides:          pakeochi
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:     1 2 3 6
# Default-Stop:      0 1 6
# Short-Description: 
# Description: 
### END INIT INFO

# env
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export SHELL=/bin/bash

DAEMON=/usr/local/bin/pakeochi
PIDFILE=/var/run/pakeochi.pid

# use log_daemon_msg & log_end_msg
. /lib/lsb/init-functions

start() {
  log_daemon_msg "Start pakeochi"

  # cheking already run?
  if start-stop-daemon --stop --quiet --signal 0 --pidfile $PIDFILE
  then
    pid=`cat ${PIDFILE}`
    echo "pakeochi is already running? (pid=${pid})"
    exit
  fi

  start-stop-daemon --start --background --quiet --oknodo --pidfile $PIDFILE --make-pidfile --chdir "/usr/local/bin/" --startas ${DAEMON}
  log_end_msg $?
}

stop() {
  log_daemon_msg "Stop pakeochi"

  # cheking already run?
  if start-stop-daemon --stop --quiet --signal 0 --pidfile $PIDFILE
  then
   #start-stop-daemon --stop --signal TERM --pidfile ${PIDFILE}
    start-stop-daemon --stop --pidfile ${PIDFILE}
    status=$?
    rm -f ${PIDFILE}
    log_end_msg $status
  else
    echo "pakeochi not running? (check ${PIDFILE})."
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: service pakeochi {start|stop|restart}" >&2
    exit 1
    ;;
esac

exit 0
