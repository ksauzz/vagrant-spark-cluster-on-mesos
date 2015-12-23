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

start_mesos_master(){
  cmd_all "\
    sudo mesos master --work_dir=/var/lib/mesos/master \
      --quorum=2 \
      --log_dir=/var/log/mesos/ \
      --zk=zk://33.33.10.10:2181,33.33.10.20:2181,33.33.10.30:2181/mesos &>/dev/null &"
}

start_mesos_slave(){
  cmd_all "\
    sudo mesos slave --work_dir=/var/lib/mesos/slave \
      --log_dir=/var/log/mesos/ \
      --master=zk://33.33.10.10:2181,33.33.10.20:2181,33.33.10.30:2181/mesos &>/dev/null &"
}

start_mesos_dispatcher(){
  cmd $1 "\
    sudo /opt/spark/sbin/start-mesos-dispatcher.sh \
      --zk 33.33.10.10:2181,33.33.10.20:2181,33.33.10.30:2181 \
      --master mesos://33.33.10.10:5050,33.33.10.20:5050,33.33.10.30:5050/mesos"
}

stop_mesos_dispatcher(){
  cmd $1 "sudo /opt/spark/sbin/stop-mesos-dispatcher.sh"
}

stop_all(){
  cmd_all "sudo killall mesos-master && sudo killall mesos-slave && sudo /opt/spark/sbin/stop-mesos-dispatcher.sh"
}

mesos_cmd() {
  vm=$1
  shift
  cmd $1 $@
}

case "$1" in
  start)
    start_mesos_master
    start_mesos_slave
    start_mesos_dispatcher spark1
    ;;
  start[-_]mesos[-_]master)
    start_mesos_master
    ;;
  start[-_]mesos[-_]slave)
    start_mesos_slave
    ;;
  start[-_]dispatcher)
    shift
    start_mesos_dispatcher $1
    ;;
  stop[-_]dispatcher)
    shift
    stop_mesos_dispatcher $1
    ;;
  stop)
    stop_all
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
