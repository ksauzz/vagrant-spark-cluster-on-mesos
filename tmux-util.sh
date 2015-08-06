#!/bin/bash

. lib/cluster-utils.sh

MESOS_MASTER_LOG=/var/log/mesos/mesos-master.INFO
MESOS_SLAVE_LOG=/var/log/mesos/mesos-slave.INFO
ZK_LOG=/var/log/zookeeper/zookeeper.log

_ssh(){
  tmux split-window -v -p 66 "vagrant ssh spark2 -- $@"
  tmux split-window -v "vagrant ssh spark3 -- $@"
  vagrant ssh spark1 -- $@
}

log_zk(){
  _ssh "tail -f $ZK_LOG"
}

log_mesos_master(){
  _ssh "tail -f $MESOS_MASTER_LOG"
}

log_mesos_slave(){
  _ssh "tail -f $MESOS_SLAVE_LOG"
}

log_spark(){
  _ssh "tail -f \"/opt/spark/logs/spark-root-org.apache.spark.deploy.mesos.MesosClusterDispatcher-1-\\\$(hostname).out\""
}

usage(){
  cat<<EOS
USAGE
-----

$0 <command>

Commands:

  ssh     : ssh login to all VMs (default)
  --help  : show this messages
EOS
}

if [ $# -eq 0 ]; then
  _ssh
fi

case "$1" in
  --help)
    usage
    ;;
  ssh)
    _ssh
    ;;
  log)
     exec_or_die log_$2
    ;;
  *)
    usage
esac
