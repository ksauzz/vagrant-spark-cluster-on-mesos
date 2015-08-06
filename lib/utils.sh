#!/bin/bash

download() {
  file=`echo $1 | sed 's/\(.*\)\/\(.*\)$/\2/'`
  if [ -f $file ]; then
    echo "$file is already found."
  elif [ -f /var/cache/wget/$file ]; then
    cp -pv /var/cache/wget/$file ./
  elif [ -d /var/cache/wget ]; then
    wget -N -P /var/cache/wget $1
    cp -pv /var/cache/wget/$file ./
  else
    wget -N $1
  fi
}

apply_jp_apt_mirror(){
  echo deb http://jp.archive.ubuntu.com/ubuntu/ precise main universe          | tee /etc/apt/sources.list
  echo deb http://jp.archive.ubuntu.com/ubuntu/ precise-security main universe | tee -a /etc/apt/sources.list
  echo deb http://jp.archive.ubuntu.com/ubuntu/ precise-updates main universe  | tee -a /etc/apt/sources.list
  apt-get update
}

install_java() {
  if [ "`which java`" != "" ]; then
    echo "Java has been already installed."
    return
  fi

  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

  apt-get install -y --no-install-recommends python-software-properties
  add-apt-repository -y ppa:webupd8team/java
  apt-get update
  apt-get install -y --no-install-recommends oracle-java8-installer
}

install_open_jdk() {
  if [ "`which java`" != "" ]; then
    echo "Java has been already installed."
    return
  fi

  add-apt-repository -y ppa:openjdk-r/ppa
  apt-get update
  apt-get install -y --no-install-recommends openjdk-8-jdk
}

increase_open_files(){
  if [ -f /etc/security/limits.d/custom.conf ]; then
    echo "openfile settings is already done."
    return
  fi
  sudo cat <<EOF > /etc/security/limits.d/custom.conf
*                   soft    nofile          524288
*                   hard    nofile          524288
EOF
}
