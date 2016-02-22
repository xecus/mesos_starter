#!/bin/bash

# Launch Service
service ssh start

if [ "${MODE}" = "master" ]; then
    # Launch ZooKeeper
    cp /home/docker/mesos-0.27.0/3rdparty/zookeeper-3.4.5/conf/zoo_sample.cfg /home/docker/mesos-0.27.0/3rdparty/zookeeper-3.4.5/conf/zoo.cfg
    /home/docker/mesos-0.27.0/3rdparty/zookeeper-3.4.5/bin/zkServer.sh start
    # Launch Mesos Master
    /home/docker/mesos-0.27.0/bin/mesos-master.sh --ip=0.0.0.0 --work_dir=/var/lib/mesos --zk=zk://localhost:2181/mesos --quorum=1 &
    sudo -u docker /home/docker/marathon/bin/start --master zk://localhost:2181/mesos --zk zk://localhost:2181/marathon --hostname localhost &
fi
if [ "${MODE}" = "slave" ]; then
    # Launch Mesos Slave
    sudo -u docker /home/docker/mesos-0.27.0/bin/mesos-slave.sh --master=zk://${MASTER}:2181/mesos
fi

# sleep
while :
do
	sleep 1
done
