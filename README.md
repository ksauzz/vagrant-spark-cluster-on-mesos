## Vagrant Spark cluster on Mesos

### Getting Started

Setup a cluster

```
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-hosts
vagrant up
./cluster-manager.sh start
```

Login to a node named spark1

```
vagrant ssh spark1
```

http://33.33.10.10:5050/ is a Web GUI endpoint.

#### Run a example, SparkPi

```
/opt/spark/bin/spark-submit --executor-memory 10M --total-executor-cores 3 --class org.apache.spark.examples.SparkPi --master mesos://33.33.10.10:7077 --deploy-mode cluster --verbose /opt/spark/lib/spark-examples-1.4.1-hadoop2.6.0.jar 100
```

mesos://33.33.10.10:7077 means spark's mesos dispatcher port.

#### Run spark-shell with mesos cluster

```
/opt/spark/bin/spark-shell --master mesos://33.33.10.10:5050,33.33.10.20:5050,33.33.10.30:5050/mesos
```
