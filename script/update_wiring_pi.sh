#!/bin/bash -e
: "check CPU Architecture" && {
  if [ `lscpu | grep Architecture: | awk '{print $2}'` != "armv7l" ] ; then
    echo "Please run this shell at Raspberry Pi!"
    exit 1
  fi
}

: "pj root" && {
  if [ -z "${PJ_ROOT}" ] ; then
    PJ_ROOT=`echo $(cd $(dirname $0);cd ../;pwd)`
  fi
}

: "pre-clean" && {
  if [ -e "${PJ_ROOT}/tmp" ] ; then
    rm -rf "${PJ_ROOT}/tmp"
  fi
}

: "git clone" && {
  git clone -q https://github.com/WiringPi/WiringPi "${PJ_ROOT}/tmp/WiringPi"
}

: "build" && {
  if [ -e "${PJ_ROOT}/tmp/WiringPi" ] ; then
    cd "${PJ_ROOT}/tmp/WiringPi"
    ./build
  else
    echo "${PJ_ROOT}/tmp/WiringPi is not found."
    exit 1
  fi
}

: "update" && {
  if [ -e "${PJ_ROOT}/tmp/WiringPi/wiringPi/libwiringPi.a" ] ; then
    mv "${PJ_ROOT}/tmp/WiringPi/wiringPi/libwiringPi.a" "${PJ_ROOT}/lib/libwiringPi.a"
  fi
}

: "clean" && {
  if [ -e "${PJ_ROOT}/tmp" ] ; then
    rm -rf "${PJ_ROOT}/tmp"
  fi
  cd "${PJ_ROOT}"
}
