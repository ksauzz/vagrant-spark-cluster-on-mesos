#!/bin/bash

. lib/cluster-utils.sh

usage(){
  cat<<EOS
USAGE
-----

$0 <command>

Commands:
  start                 : Start a cluster
  cmd-all <command>     : Execute command on all machines

EOS
}

start_cluster(){
  cmd_all "\
    sudo mesos master --work_dir=/var/lib/mesos/master \
    --quorum=2 \
    --log_dir=/var/log/mesos/ \
    --zk=zk://33.33.10.10:2181,33.33.10.20:2181,33.33.10.30:2181/mesos &>/dev/null &"

  cmd_all "\
    sudo mesos slave --work_dir=/var/lib/mesos/slave \
    --log_dir=/var/log/mesos/ \
    --master=zk://33.33.10.10:2181,33.33.10.20:2181,33.33.10.30:2181/mesos &>/dev/null &"
}

stop_cluster(){
  cmd_all "sudo killall mesos-master && sudo killall mesos-slave"
}

mesos_cmd() {
  vm=$1
  shift
  cmd $1 $@
}

case "$1" in
  start)
    start_cluster
    ;;
  stop)
    stop_cluster
    ;;
  cmd-all)
    shift
    cmd_all $@
    ;;
  mesos)
    shift
    exec_or_die mesos_cmd $@
    ;;
  *)
    usage
esac
