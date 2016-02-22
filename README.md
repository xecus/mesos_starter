mesos_docker
___

# Build Image
```
ssh-keygen -t rsa -f
docker build -t mesos_docker:0.1.0 ./
```


# Run Container (Master)
```
docker run --restart=always -d --name mesos_container_master -e MODE=master mesos_docker:0.1.0
```

# Run Container (Slave)
```
docker run --restart=always -d --name mesos_container_slave_1 -e MODE=slave -e MASTER=<Master IP> mesos_docker:0.1.0
docker run --restart=always -d --name mesos_container_slave_2 -e MODE=slave -e MASTER=<Master IP> mesos_docker:0.1.0
docker run --restart=always -d --name mesos_container_slave_3 -e MODE=slave -e MASTER=<Master IP> mesos_docker:0.1.0
```
