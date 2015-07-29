#!/bin/bash

. /vagrant/lib/utils.sh

HOSTNAME=$1
ADDRESS=$2

MESOS_VERSION=0.23.0

install_mesos() {
  echo "Installing mesos..."
  # Setup
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
  DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
  CODENAME=$(lsb_release -cs)

  # Add the repository
  echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" |  sudo tee /etc/apt/sources.list.d/mesosphere.list
  sudo apt-get -y update
  sudo apt-get -y install mesos=$MESOS_VERSION-1.0.ubuntu1204
}

update_zk_config() {
  echo "Updating zookeeper's config..."
  sed -i.back 's/#server.1=zookeeper1:2888:3888/server.1=33.33.10.10:2888:3888/' /etc/zookeeper/conf/zoo.cfg
  sed -i.back 's/#server.2=zookeeper2:2888:3888/server.2=33.33.10.20:2888:3888/' /etc/zookeeper/conf/zoo.cfg
  sed -i.back 's/#server.3=zookeeper3:2888:3888/server.3=33.33.10.30:2888:3888/' /etc/zookeeper/conf/zoo.cfg
  echo `echo $HOSTNAME|egrep -o [0-9]+` > /etc/zookeeper/conf/myid

  sed -i 's/JAVA_OPTS=""/JAVA_OPTS="-Djava.net.preferIPv4Stack=true"/' /etc/zookeeper/conf/environment

  # workaroud for https://bugs.launchpad.net/ubuntu/+source/zookeeper/+bug/888643
  echo "Restart zookeeper process to apply the changes..."

  service zookeeper restart
}

update_hosts() {
  sed -i.back "s/127.0.1.1/$ADDRESS/" /etc/hosts
}

update_hosts
increase_open_files
install_mesos
update_zk_config
