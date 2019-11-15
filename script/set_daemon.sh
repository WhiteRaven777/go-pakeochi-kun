#!/bin/bash -e
: "pj root" && {
  if [ -z "${PJ_ROOT}" ] ; then
    PJ_ROOT=`echo $(cd $(dirname $0);cd ../;pwd)`
  fi
}

: "setup daemon script" && {
  cd ${PJ_ROOT}
  if [ -e "${PJ_ROOT}/script/daemon_script/pakeochi.sh" ] ; then
    sudo cp -f "${PJ_ROOT}/script/daemon_script/pakeochi.sh" "/etc/init.d/pakeochi"
  fi
  if [ -e "/etc/init.d/pakeochi" ] ; then
    sudo insserv -r "/etc/init.d/pakeochi" || true
    sudo insserv -d "/etc/init.d/pakeochi"
  fi
}
