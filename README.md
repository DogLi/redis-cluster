redis-cluster
------

Redis 主从机器 k8s 的搭建

使用`Statefulset`来创建主从集群，使用`HostPath`的方式来存储数据

# 编译镜像
`cd imag && ./build.sh`
请更改私有仓库地址

# 创建集群

## 1. 在宿主机上创建目录以映射到pod中
`mkdir -p /opt/redis/{master,slave}-data`

## 2. 创建配置文件

`kubectl create -f redis.config.yaml`
密码配置的默认为`root`,可自行更改： `echo PASSWORD | base64`

## 3. 创建master
`kubectl create -f redis_master.statefulset.yaml`

## 4. 创建slave
`kubectl create -f redis_slave.statefulset.yaml`
