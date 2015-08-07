#!/bin/bash

cmd() {
  host=$1
  shift
  echo "# Running \"$@\" on $host..."
  vagrant ssh $host -- "$@"
  echo "# Done."
  echo
}

cmd_no_echo() {
  host=$1
  shift
  vagrant ssh $host -- "$@"
}

cmd_all() {
  for host in `vagrant status | grep running | awk '{print $1}'`; do
    cmd $host "$@"
  done
}

exec_or_die() {
  type -t $1 > /dev/null
  if [ $? -gt 0 ]; then
    usage
    exit 1
  fi
  $1
}
