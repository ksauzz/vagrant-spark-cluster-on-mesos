#!/bin/bash

. /vagrant/lib/utils.sh

HOSTNAME=$1
ADDRESS=$2

MESOS_VERSION=0.23.0
SPARK_VERSION=1.4.1

install_mesos() {
  echo "Installing mesos..."
  # Setup
  apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
  DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
  CODENAME=$(lsb_release -cs)

  # Add the repository
  echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" |  sudo tee /etc/apt/sources.list.d/mesosphere.list
  apt-get -y update
  apt-get -y install mesos=$MESOS_VERSION-1.0.ubuntu1204
}

# Mesos driver requires newer libstdc++6
upgrade_libstdc(){
  echo "Upgrading libstdc++6..."
  apt-get -y install python-software-properties
  add-apt-repository ppa:ubuntu-toolchain-r/test
  apt-get update
  apt-get -y install libstdc++6
}

install_spark() {
  echo "Installing spark..."
  download http://ftp.riken.jp/net/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
  tar zxfv spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
  mv spark-${SPARK_VERSION}-bin-hadoop2.6 /opt/
  ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop2.6 /opt/spark
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

increase_open_files
upgrade_libstdc
install_open_jdk
install_mesos
install_spark
update_zk_config
