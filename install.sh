#!/bin/bash -e
: "pj root" && {
  PJ_ROOT=`echo $(cd $(dirname $0);cd ./;pwd)`
}

: "update WiringPi" && {
  cd ${PJ_ROOT}
  source ./script/update_wiring_pi.sh
}

: "build " && {
  echo =====================
  echo build pakepchi
  cd ${PJ_ROOT}
  source ./script/build.sh
}

: "setup " && {
  echo =====================
  echo setup pakepchi daeomon
  cd ${PJ_ROOT}
  source ./script/set_daemon.sh
  echo please restart!
}

echo =====================
echo success.
