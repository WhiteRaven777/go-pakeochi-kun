#!/bin/bash -e
: "pj root" && {
  if [ -z "${PJ_ROOT}" ] ; then
    PJ_ROOT=`echo $(cd $(dirname $0);cd ../;pwd)`
  fi
}

: "check GOPATH" && {
  if [ -n "${GOPATH}" ] ; then
    if [ ! `echo ${GOPATH} | grep ${PJ_ROOT}` ] ; then
      GOPATH=${GOPATH}:${PJ_ROOT}
    fi
  else
    echo "GOPATH has not been set."
  fi
}

: "build" && {
  cd ${PJ_ROOT}
  GOOS=`uname | tr \‘[A-Z]\’ \‘[a-z]\’`
  GOARCH=arm
  GOARM=`cat /proc/cpuinfo | grep "CPU architecture" | head -n 1 | awk '{print $3}'`
  if [ -e "${PJ_ROOT}/tmp" ] ; then
    rm -rf "${PJ_ROOT}/tmp"
  fi
  mkdir tmp

  go build -o "${PJ_ROOT}/tmp/pakeochi" -tags=release "${PJ_ROOT}/src/pakeochi.go"

  sudo mv "${PJ_ROOT}/tmp/pakeochi" "/usr/local/bin/pakeochi"
  sudo chown root:root "/usr/local/bin/pakeochi"
  if [ -e "${PJ_ROOT}/tmp" ] ; then
    rm -rf "${PJ_ROOT}/tmp"
  fi
}