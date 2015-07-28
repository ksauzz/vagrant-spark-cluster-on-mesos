#!/bin/bash

. lib/cluster-utils.sh

usage(){
  cat<<EOS
USAGE
-----

$0 <command>

Commands:
  service [start|stop]  : Manage service on all machines
  cmd-all <command>     : Execute command on all machines

EOS
}

service_start() {
  cmd_all "sudo xxxx start"
}

service_stop() {
  cmd_all "sudo xxxx stop"
}

case "$1" in
  cmd-all)
    shift
    cmd_all $@
    ;;
  service)
    exec_or_die service_$2
    ;;
  *)
    usage
esac
