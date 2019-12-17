---
title: MongoDB集群
date: 2018-03-15 09:45:35
updated: 2018-03-15 09:45:35
tags:
- 服务器
- 数据库
- 后端
- MongoDB
categories:
- 数据库
- mongoDB
---

目的：使用三个docker虚拟容器创建mongoDB集群

## 1、拉取镜像

可配置阿里云的[镜像加速器](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)

```
> sudo mkdir -p /etc/docker
> sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://test.mirror.aliyuncs.com"]
}
EOF
> sudo systemctl daemon-reload
> sudo systemctl restart docker
```

## 2、创建docker-compose文件

注意，docker-compose的文件名需要是`docker-compose.yml`

这里采用的mongo4.0的镜像，每个容器最大内存限制为4G

```
version: '2'
services:
  db0:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db0:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27018:27017"
    command: mongod --replSet rs0
    links:
      - db1
      - db2
      
  db1:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db1:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27019:27017"
    command: mongod --replSet rs0
    
  db2:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db2:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27020:27017"
    command: mongod --replSet rs0
```

## 3、创建容器

在docker-compost.yml的相同路径下，执行`docker-compose up -d`，这样使用`docker ps`就可以看到有三个容器启动，选择一个容器进入`docker exec -it containerid bash`

-  执行`mongo`

  ```
  > use admin
  > config = {
        "_id" : "rs0",
        "members" : [
            {
                "_id" : 0,
                "host" : "192.168.1.44:27018",
                "priority":2 # 为权重
            },
            {
                "_id" : 1,
                "host" : "192.168.1.44:27019"
            },
            {
                "_id" : 2,
                "host" : "192.168.1.44:27020"
            }
        ]
    }
    
  > rs.initiate(config)
  ```

  此时可以使用`rs.status()`查看集群信息，`rs.isMaster()`查看当前节点是否是主节点

- 创建用户

  要操作哪个库，就在哪个库下创建用户

  ```
  use admin
  
  - db.createUser({user: 'user', pwd: 'pwd', roles: [{role:'root', db: 'admin'}]})
  ```

  - role

  1. 数据库用户角色：read、readWrite;
  2. 数据库管理角色：dbAdmin、dbOwner、userAdmin；
  3. 集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
  4. 备份恢复角色：backup、restore；
  5. 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
  6. 超级用户角色：root
     // 这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
  7. 内部角色：__system

  删除用户`db.dropUser('username')`

  查看用户`show users`

  ```
  read：允许用户读取指定数据库
  readWrite：允许用户读写指定数据库
  dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
  userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
  clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
  readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
  readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
  userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
  dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
  root：只在admin数据库中可用。超级账号，超级权限
  ```

- `openssl rand -base64 725  > /data/common/mongodb-keyfile`生成密钥，长度大小要求在6-1024之间

- 配置权限，更改所有者和所属组

  `chmod 600 mongodb-keyfile`

  `chown 999:999 mongodb-keyfile`

  注：docker容器的所属组为999

## 4、配置登录

重新配置`docker-compose.yml`

```
version: '2'
services:
  db0:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db0:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27018:27017"
    command: mongod --replSet rs0 --auth --keyFile /data/common/mongodb-keyfile
    links:
      - db1
      - db2
      
  db1:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db1:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27019:27017"
    command: mongod --replSet rs0 --auth --keyFile /data/common/mongodb-keyfile
    
  db2:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db2:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27020:27017"
    command: mongod --replSet rs0 --auth --keyFile /data/common/mongodb-keyfile
```

不加`--auth` ，数据库就可以不通过密码登录，当忘记密码时，可以使用。

此时要先将容器停止，`docker-compose stop`，再使用`docker-compose up` 新建并启动镜像

## 5、连接

mongodb://用户名:密码@集群1，集群2，集群3/要操作的数据库?authSource=用户具有的权限库&replicaSet=分片名

`mongodb://user:pwd@192.168.1.44:27018,192.168.1.44:27019,192.168.1.44:27020/data?authSource=admin&replicaSet=rs0`

这是在admin库下创建的一个root权限的用户，authsource为admin，要操作data表，分片名为rs0

##附：数据备份与还原

- 备份

  `mongodump -h $DB_HOST -u $DB_USER -p $DB_PASS --authenticationDatabase admin -d $DB_NAME -o $OP_DIR --forceTableScan`

  mongodump -h dbhost -d dbname -o dbdirectory
  -h：MongDB所在服务器地址，例如：127.0.0.1，当然也可以指定端口号：127.0.0.1:27017
  -d：需要备份的数据库实例，例如：test
  -o：备份的数据存放位置，例如：/root/data/dump，当然该目录需要提前建立，在备份完成后，系统自动在dump目录下建立一个test目录，这个目录里面存放该数据库实例的备份数据。

  -u 用户名

  -p 密码

  --authenticationDatabase 登录的用户验证的数据库

  --forceTableScan 不使用任何索引的情况下扫描数据

- 还原

  `mongorestore -u xx-p xx --authenticationDatabase admin -d data .`

  mongorestore 默认是追加， 可以加--drop清空后恢复

- 附：

  `--batchSize=num` 可以选择每次操作的文档数量，来限制mongo操作时使用的内存大小

`--gzip`
  可选的。适用于mongodump > = 3.2，启用备份文件的内联压缩。

  `--oplog` 在备份过程中，保留`oplog`，可以在恢复数据的时候进行操作重现，保证在备份过程中新的操作也可以被保留

  任何replset成员都需要！此参数使“mongodump”在备份过程中捕获oplog更改日志，以保持一致的时间点。

  恢复：`mongorestore -u xx-p xx --authenticationDatabase admin . --oplogReplay`

它的实际作用是在导出的同时生成一个oplog.bson文件，存放在你开始进行dump到dump结束之间所有的oplog。用图形来说明下oplog.bson的覆盖范围：
  ![mongodump_oplog](http://www.fordba.com/wp-content/uploads/2018/04/mongodump_oplog.png)

  注意：mongodump时，--oplog只能在master节点（主从结构）或者副本集的成员中执行。也就是说，mongodump --oplog不能在主从结构的slave上执行